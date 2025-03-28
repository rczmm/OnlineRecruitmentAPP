import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/widgets/chat_bubble.dart';

import 'common_phrases_page.dart';

class ChatScreen extends StatefulWidget {
  final String peerName;
  final String peerId;
  final String? peerAvatarUrl;

  const ChatScreen({
    super.key,
    required this.peerName,
    required this.peerId,
    this.peerAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // For auto-scrolling
  final List<ChatMessage> _messages = [];

  List<Map<String, dynamic>> _userFiles = [];
  bool _isLoadingFiles = false;

  final bool _isUploading = false;
  final double _uploadProgress = 0.0;

  final String _fetchFilesUrl = 'http://127.0.0.1:8088/api/user/my-files';
  final Dio _dio = DioClient().dio;

  WebSocketChannel? _channel;
  String _myUserId = "unknown_user";

  final String _myAvatarUrl =
      "https://via.placeholder.com/150/0000FF/FFFFFF?text=Me";
  String _peerAvatarUrl =
      "https://via.placeholder.com/150/FF0000/FFFFFF?text=Peer";

  final _storage = const FlutterSecureStorage();
  Timer? _reconnectTimer;

  final String _websocketBaseUrl = 'ws://127.0.0.1:8088/chat';
  final Duration _reconnectDelay = const Duration(seconds: 5);

  Future<void> _fetchUserFiles() async {
    if (_isLoadingFiles) return;

    setState(() {
      _isLoadingFiles = true;
    });

    try {
      String? authToken = await _storage.read(key: 'authToken');
      Options options = Options();
      if (authToken != null && authToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $authToken'};
      }

      debugPrint("Fetching user files from $_fetchFilesUrl...");
      Response response = await _dio.get(
        _fetchFilesUrl,
        options: options,
      );

      debugPrint("Fetch files response status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> fetchedFiles = [];
        for (var item in (response.data as List)) {
          if (item is Map<String, dynamic> &&
              item['fileName'] != null &&
              item['fileUrl'] != null) {
            fetchedFiles.add({
              'fileName': item['fileName'].toString(),
              'fileUrl': item['fileUrl'].toString(),
              'id': item['id']?.toString(),
            });
          }
        }
        setState(() {
          _userFiles = fetchedFiles;
        });
        debugPrint("Fetched ${_userFiles.length} files.");
      } else {
        _showErrorSnackBar("无法加载文件列表 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("DioError fetching files: $e");
      _showErrorSnackBar("加载文件列表失败: ${e.message}");
    } catch (e) {
      debugPrint("Error fetching files: $e");
      _showErrorSnackBar("加载文件列表时发生未知错误");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _peerAvatarUrl = widget.peerAvatarUrl ?? _peerAvatarUrl;
    _getUserIdAndConnect();
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close(WebSocketStatus.normalClosure, 'User left chat');
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showInfoSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              _uploadProgress > 0
                  ? CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 2,
                      color: Colors.white)
                  : const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(minutes: 1),
        ),
      );
    }
  }

  Future<void> _getUserIdAndConnect() async {
    try {
      String? storedUserId = await _storage.read(key: 'userId');
      String? authToken = await _storage.read(key: 'authToken');

      if (storedUserId == null || storedUserId.isEmpty) {
        debugPrint(
            'Warning: userId not found in secure storage. Using default.');
        _myUserId = "guest_${DateTime.now().millisecondsSinceEpoch}";
      } else {
        _myUserId = storedUserId;
      }

      debugPrint('My User ID: $_myUserId');
      debugPrint('Connecting to chat with Peer ID: ${widget.peerId}');

      _connectWebSocket(authToken);
    } catch (e) {
      debugPrint("Error reading from secure storage: $e");
      _showErrorSnackBar("无法加载用户信息，请稍后重试");
    }
  }

  void _connectWebSocket([String? authToken]) {
    _channel?.sink.close();
    _reconnectTimer?.cancel();

    try {
      String wsUrl = '$_websocketBaseUrl?userId=$_myUserId';
      if (authToken != null && authToken.isNotEmpty) {
        wsUrl += '&token=$authToken';
      }

      debugPrint('Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint('WebSocket connection initiated.');

      _channel!.stream.listen(
        _onMessageReceived,
        onError: _onWebSocketError,
        onDone: _onWebSocketDone,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WebSocket connection failed to initiate: $e');
      _showErrorSnackBar('无法连接到聊天服务器');
      _scheduleReconnect();
    }
  }

  void _onMessageReceived(dynamic message) {
    debugPrint('Received raw message: $message');
    try {
      final decodedMessage = jsonDecode(message as String);

      final senderId = decodedMessage['senderId']?.toString();
      final text = decodedMessage['text']?.toString();

      if (senderId == null || text == null) {
        debugPrint('Received incomplete message: $message');
        return;
      }

      if (senderId == widget.peerId || senderId == _myUserId) {
        final bool isMe = senderId == _myUserId;
        setState(() {
          _messages.add(ChatMessage(
            sender: isMe ? '我' : widget.peerName,
            text: text,
            isMe: isMe,
            avatarUrl: isMe ? _myAvatarUrl : _peerAvatarUrl,
          ));
        });
        _scrollToBottom();
      } else {
        debugPrint('Received message from unexpected sender: $senderId');
      }
    } catch (e) {
      debugPrint('Error decoding message: $e');
      debugPrint('Raw message content: $message');
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _showErrorSnackBar('聊天连接错误');
    _channel = null;
    _scheduleReconnect();
  }

  void _onWebSocketDone() {
    debugPrint('WebSocket connection closed.');
    if (mounted) {
      _showErrorSnackBar('聊天连接已断开');
      _channel = null;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (mounted) {
      debugPrint(
          'Scheduling reconnection in ${_reconnectDelay.inSeconds} seconds...');
      _reconnectTimer = Timer(_reconnectDelay, () {
        debugPrint("Attempting to reconnect...");
        _getUserIdAndConnect();
      });
    }
  }

  void _sendMessage() {
    final textToSend = _controller.text.trim();
    if (textToSend.isNotEmpty && _channel != null) {
      final message = {
        'recipientId': widget.peerId,
        'text': textToSend,
      };
      final jsonMessage = jsonEncode(message);

      try {
        debugPrint('Sending message: $jsonMessage');
        _channel!.sink.add(jsonMessage);

        setState(() {
          _messages.add(ChatMessage(
            sender: '我',
            text: textToSend,
            isMe: true,
            avatarUrl: _myAvatarUrl,
          ));
          _controller.clear();
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Error sending message: $e");
        _showErrorSnackBar("消息发送失败");
      }
    } else if (_channel == null) {
      _showErrorSnackBar("无法发送消息：未连接到服务器");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendWebSocketMessage(
      Map<String, dynamic> messagePayload, String displayText,
      {bool isFile = false, String? fileUrl, String? fileName}) {
    if (_channel != null) {
      try {
        final jsonMessage = jsonEncode(messagePayload);
        debugPrint('Sending message: $jsonMessage');
        _channel!.sink.add(jsonMessage);

        setState(() {
          _messages.add(ChatMessage(
            sender: '我',
            text: displayText,
            isMe: true,
            avatarUrl: _myAvatarUrl,
            isFile: isFile,
            fileUrl: fileUrl,
            fileName: fileName,
          ));
          if (!isFile) {
            _controller.clear();
          }
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Error sending message: $e");
        _showErrorSnackBar("消息发送失败");
      }
    } else {
      _showErrorSnackBar("无法发送消息：未连接");
    }
  }

  Future<void> _handleAttachment() async {
    if (_userFiles.isEmpty && !_isLoadingFiles) {
      await _fetchUserFiles();
      if (_userFiles.isEmpty) {
        if (!_isLoadingFiles) {
          _showErrorSnackBar("没有可用的附件文件。");
        }
        return;
      }
    } else if (_isLoadingFiles) {
      _showInfoSnackBar("正在加载文件列表，请稍候...");
      return;
    }

    _showFileSelectionDialog();
  }

  void _showFileSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择要发送的附件'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.4,
            child: _userFiles.isEmpty
                ? const Center(child: Text('没有找到文件。'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _userFiles.length,
                    itemBuilder: (context, index) {
                      final file = _userFiles[index];
                      final fileName = file['fileName'] ?? '未知文件';
                      final fileUrl = file['fileUrl'];

                      if (fileUrl == null) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(fileName),
                        onTap: () {
                          Navigator.of(context).pop();

                          final message = {
                            'type': 'file',
                            'recipientId': widget.peerId,
                            'fileUrl': fileUrl,
                            'fileName': fileName,
                            'text': '发送了附件: $fileName',
                          };

                          _sendWebSocketMessage(
                            message,
                            '附件: $fileName',
                            isFile: true,
                            fileUrl: fileUrl,
                            fileName: fileName,
                          );
                          _showSuccessSnackBar("已发送附件: $fileName");
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<List<CommonPhrase>> _fetchPhrasesOnce(String userId) async {
    final Dio dio = DioClient().dio;

    try {
      final response = await dio.get(
        '/commonPhrases/list',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          List<dynamic> dataList = response.data['data'] ?? [];
          if (dataList.every((item) => item is Map<String, dynamic>)) {
            List<CommonPhrase> phrases = dataList
                .map((json) =>
                    CommonPhrase.fromJson(json as Map<String, dynamic>))
                .toList();
            return phrases;
          }
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint("DioError fetching common phrases: $e");
      return [];
    } catch (e) {
      debugPrint("Error fetching common phrases: $e");
      return [];
    }
  }

  void _showSelectPhraseDialog(String currentUserId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        debugPrint("我开始渲染了");
        return AlertDialog(
          title: const Text('选择常用语'),
          content: FutureBuilder<List<CommonPhrase>>(
            future: _fetchPhrasesOnce(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Text('加载常用语失败: ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData) {
                final phrases = snapshot.data!;
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: phrases.length,
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      return ListTile(
                        title: Text(phrase.text),
                        onTap: () {
                          _sendMessageFromPhrase(phrase.text);
                          Navigator.pop(dialogContext);
                        },
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text('没有常用语'),
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _sendMessageFromPhrase(String phrase) {
    if (_channel != null) {
      final message = {
        'recipientId': widget.peerId,
        'text': phrase,
      };
      final jsonMessage = jsonEncode(message);

      try {
        debugPrint('Sending phrase: $jsonMessage');
        _channel!.sink.add(jsonMessage);

        setState(() {
          _messages.add(ChatMessage(
            sender: '我',
            text: phrase,
            isMe: true,
            avatarUrl: _myAvatarUrl,
          ));
        });
        _scrollToBottom();
      } catch (e) {
        debugPrint("Error sending phrase: $e");
        _showErrorSnackBar("发送常用语失败");
      }
    } else {
      _showErrorSnackBar("无法发送常用语：未连接到服务器");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${widget.peerName} 聊天'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration:
                  BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withAlpha(7),
                )
              ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.attach_file),
                    onPressed: _isLoadingFiles ? null : _handleAttachment,
                    tooltip: '发送附件',
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () async {
                      final String currentUserId = _myUserId;
                      if (currentUserId == "unknown_user") {
                        _showErrorSnackBar('无法获取用户信息，无法加载常用语。');
                        return;
                      }
                      _showSelectPhraseDialog(currentUserId);
                    },
                    tooltip: '常用语',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    tooltip: '发送',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final String avatarUrl;

  final bool isFile;
  final String? fileName;
  final String? fileUrl;

  const ChatMessage({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.avatarUrl,
    this.isFile = false,
    this.fileName,
    this.fileUrl,
  });

  Future<void> _launchFileUrl() async {
    if (fileUrl != null) {
      final Uri uri = Uri.parse(fileUrl!);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $fileUrl');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFile) {
      return ChatBubble(
        isSender: isMe,
        avatarUrl: avatarUrl,
        message: '',
        child: InkWell(
          onTap: _launchFileUrl,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file,
                    size: 20, color: isMe ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    fileName ?? '附件', // Display filename
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return ChatBubble(
        message: text,
        isSender: isMe,
        avatarUrl: avatarUrl,
      );
    }
  }
}

class WebSocketStatus {
  static const int normalClosure = 1000;
}
