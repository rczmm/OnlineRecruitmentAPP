import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/services/dio_client.dart';
import '../widgets/chat_bubble.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String peerName; // The name of the user you are chatting with
  final String peerId; // The user ID of the user you are chatting with
  // Optional: Pass peer's avatar URL if available
  final String? peerAvatarUrl;

  const ChatScreen({
    super.key,
    required this.peerName,
    required this.peerId,
    this.peerAvatarUrl, // Add peerAvatarUrl
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

  bool _isUploading = false;
  double _uploadProgress = 0.0; // Optional: for

  final String _fetchFilesUrl =
      'http://127.0.0.1:8088/api/user/my-files'; // EXAMPLE URL!
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

  // --- Fetch User's Pre-Uploaded Files ---
  Future<void> _fetchUserFiles() async {
    if (_isLoadingFiles) return; // Don't fetch if already loading

    setState(() {
      _isLoadingFiles = true;
    });
    // Optional: Show feedback
    // _showLoadingSnackBar("正在加载文件列表...");

    try {
      // Retrieve auth token if needed by your backend
      String? authToken = await _storage.read(key: 'authToken');
      Options options = Options();
      if (authToken != null && authToken.isNotEmpty) {
        options.headers = {'Authorization': 'Bearer $authToken'};
      }

      print("Fetching user files from $_fetchFilesUrl...");
      Response response = await _dio.get(
        _fetchFilesUrl,
        options: options,
      );

      print("Fetch files response status: ${response.statusCode}");
      // print("Fetch files response data: ${response.data}");

      if (response.statusCode == 200 && response.data is List) {
        // Assuming backend returns List<Map<String, dynamic>>
        // Perform type checking for safety
        List<Map<String, dynamic>> fetchedFiles = [];
        for (var item in (response.data as List)) {
          if (item is Map<String, dynamic> &&
              item['fileName'] != null &&
              item['fileUrl'] != null) {
            fetchedFiles.add({
              'fileName': item['fileName'].toString(),
              'fileUrl': item['fileUrl'].toString(),
              // Add other fields like 'id' if needed
              'id': item['id']?.toString(),
            });
          }
        }
        setState(() {
          _userFiles = fetchedFiles;
        });
        print("Fetched ${_userFiles.length} files.");
        // Optional: Hide loading snackbar
        // ScaffoldMessenger.of(context).removeCurrentSnackBar();
      } else {
        _showErrorSnackBar("无法加载文件列表 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      print("DioError fetching files: $e");
      _showErrorSnackBar("加载文件列表失败: ${e.message}");
    } catch (e) {
      print("Error fetching files: $e");
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
    _reconnectTimer?.cancel(); // Cancel timer if active
    _channel?.sink.close(
        WebSocketStatus.normalClosure, 'User left chat'); // Close WebSocket
    _controller.dispose();
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void _showInfoSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // Use progress value if available, otherwise indeterminate
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
          duration:
              const Duration(minutes: 1), // Keep visible longer during upload
        ),
      );
    }
  }

  Future<void> _getUserIdAndConnect() async {
    try {
      String? storedUserId = await _storage.read(key: 'userId');
      String? authToken = await _storage.read(key: 'authToken');

      if (storedUserId == null || storedUserId.isEmpty) {
        print('Warning: userId not found in secure storage. Using default.');
        // Handle this case more robustly in a real app (e.g., force login)
        _myUserId = "guest_${DateTime.now().millisecondsSinceEpoch}";
      } else {
        _myUserId = storedUserId;
      }

      print('My User ID: $_myUserId');
      print('Connecting to chat with Peer ID: ${widget.peerId}');

      // Now connect
      _connectWebSocket(authToken);
    } catch (e) {
      print("Error reading from secure storage: $e");
      _showErrorSnackBar("无法加载用户信息，请稍后重试");
      // Decide how to proceed - maybe prevent connection?
    }
  }

  void _connectWebSocket([String? authToken]) {
    // Ensure previous connection and timer are cleaned up
    _channel?.sink.close();
    _reconnectTimer?.cancel();

    try {
      // Construct WebSocket URL
      // Note: Ensure _websocketBaseUrl is correct for your environment
      // (e.g., use local IP like 192.168.x.x if server is on another machine in LAN)
      String wsUrl = '$_websocketBaseUrl?userId=$_myUserId';
      if (authToken != null && authToken.isNotEmpty) {
        // Consider security implications of token in URL
        wsUrl += '&token=$authToken';
      }

      print('Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('WebSocket connection initiated.');

      // Listen for messages
      _channel!.stream.listen(
        _onMessageReceived,
        onError: _onWebSocketError,
        onDone: _onWebSocketDone,
        cancelOnError: true, // Automatically cancels subscription on error
      );

      // Optional: Send a confirmation/hello message upon connection if needed by server
      // _channel?.sink.add(jsonEncode({'type': 'status', 'status': 'connected'}));
    } catch (e) {
      print('WebSocket connection failed to initiate: $e');
      _showErrorSnackBar('无法连接到聊天服务器');
      _scheduleReconnect(); // Schedule reconnection on initial connection failure
    }
  }

  void _onMessageReceived(dynamic message) {
    debugPrint('Received raw message: $message');
    try {
      final decodedMessage = jsonDecode(message as String);

      // --- Adapt based on your actual server message format ---
      final senderId = decodedMessage['senderId']?.toString();
      final text = decodedMessage['text']?.toString();
      // final messageType = decodedMessage['type'] ?? 'text'; // Example: handle different types

      if (senderId == null || text == null) {
        debugPrint('Received incomplete message: $message');
        return; // Ignore incomplete messages
      }
      // ---------------------------------------------------------

      // Only add messages relevant to this chat (from peer or self echo)
      // Assumes server echoes back sent messages or filters appropriately
      if (senderId == widget.peerId || senderId == _myUserId) {
        final bool isMe = senderId == _myUserId;
        setState(() {
          _messages.add(ChatMessage(
            // Display '我' for self, peerName for peer
            sender: isMe ? '我' : widget.peerName,
            text: text,
            isMe: isMe,
            // Use correct avatar based on sender
            avatarUrl: isMe ? _myAvatarUrl : _peerAvatarUrl,
          ));
        });
        _scrollToBottom(); // Scroll down when a new message arrives
      } else {
        print('Received message from unexpected sender: $senderId');
      }
    } catch (e) {
      print('Error decoding message: $e');
      print('Raw message content: $message');
      // Optionally show a less intrusive error indicator
      // _showErrorSnackBar('收到无法解析的消息');
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('WebSocket Error: $error');
    _showErrorSnackBar('聊天连接错误');
    _channel = null; // Mark channel as unusable
    _scheduleReconnect();
  }

  void _onWebSocketDone() {
    debugPrint('WebSocket connection closed.');
    // Check if closure was expected (e.g., during dispose)
    if (mounted) {
      // Only reconnect if the widget is still active
      _showErrorSnackBar('聊天连接已断开');
      _channel = null; // Mark channel as unusable
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    // Avoid scheduling multiple timers
    _reconnectTimer?.cancel();
    if (mounted) {
      // Only schedule if widget is mounted
      print(
          'Scheduling reconnection in ${_reconnectDelay.inSeconds} seconds...');
      _reconnectTimer = Timer(_reconnectDelay, () {
        print("Attempting to reconnect...");
        _getUserIdAndConnect(); // Retry the whole process including fetching ID/token
      });
    }
  }

  void _sendMessage() {
    final textToSend = _controller.text.trim();
    if (textToSend.isNotEmpty && _channel != null) {
      final message = {
        'recipientId': widget.peerId, // Send to the peer
        'text': textToSend,
        // Optional: Include senderId if server requires it
        // 'senderId': _myUserId,
        // Optional: Add a message type if needed
        // 'type': 'text'
      };
      final jsonMessage = jsonEncode(message);

      try {
        print('Sending message: $jsonMessage');
        _channel!.sink.add(jsonMessage);

        // Add message locally immediately for better UX
        setState(() {
          _messages.add(ChatMessage(
            sender: '我', // Always '我' for messages sent by the user
            text: textToSend,
            isMe: true,
            avatarUrl: _myAvatarUrl, // Use current user's avatar
          ));
          _controller.clear();
        });
        _scrollToBottom(); // Scroll after sending
      } catch (e) {
        print("Error sending message: $e");
        _showErrorSnackBar("消息发送失败");
        // Consider adding the message with a 'failed' status locally
      }
    } else if (_channel == null) {
      _showErrorSnackBar("无法发送消息：未连接到服务器");
    }
  }

  // Helper to scroll ListView to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Schedule scroll after the frame build is complete
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
        print('Sending message: $jsonMessage');
        _channel!.sink.add(jsonMessage);

        // Add message locally immediately
        setState(() {
          _messages.add(ChatMessage(
            sender: '我',
            text: displayText,
            isMe: true,
            avatarUrl: _myAvatarUrl,
            // Make sure _myAvatarUrl is defined
            isFile: isFile,
            fileUrl: fileUrl,
            fileName: fileName,
          ));
          if (!isFile) {
            // Only clear text field for text messages
            _controller.clear();
          }
        });
        _scrollToBottom(); // Make sure _scrollToBottom is defined
      } catch (e) {
        print("Error sending message: $e");
        _showErrorSnackBar("消息发送失败"); // Make sure _showErrorSnackBar is defined
      }
    } else {
      _showErrorSnackBar(
          "无法发送消息：未连接"); // Make sure _showErrorSnackBar is defined
    }
  }

// --- Handle Attachment Button Press ---
  Future<void> _handleAttachment() async {
    // 1. Fetch files if list is empty (or always refresh if desired)
    if (_userFiles.isEmpty && !_isLoadingFiles) {
      await _fetchUserFiles();
      // If fetching failed or list is still empty after fetch, show error and return
      if (_userFiles.isEmpty) {
        if (!_isLoadingFiles) { // Only show error if not still loading
          _showErrorSnackBar("没有可用的附件文件。");
        }
        return;
      }
    } else if (_isLoadingFiles) {
      _showInfoSnackBar("正在加载文件列表，请稍候...");
      return; // Don't show dialog while loading
    }

    // 2. Show the selection dialog
    _showFileSelectionDialog();
  }

  // --- Show Dialog for File Selection ---
  void _showFileSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择要发送的附件'),
          content: SizedBox(
            width: double.maxFinite, // Use available width
            // Constrain height if list can be long
            height: MediaQuery.of(context).size.height * 0.4,
            child: _userFiles.isEmpty
                ? const Center(child: Text('没有找到文件。'))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: _userFiles.length,
              itemBuilder: (context, index) {
                final file = _userFiles[index];
                final fileName = file['fileName'] ?? '未知文件';
                final fileUrl = file['fileUrl']; // Needed for sending

                if (fileUrl == null) return const SizedBox.shrink(); // Skip if no URL

                return ListTile(
                  leading: const Icon(Icons.description_outlined), // Or other appropriate icon
                  title: Text(fileName),
                  onTap: () {
                    // --- File Selected ---
                    Navigator.of(context).pop(); // Close the dialog

                    // Construct the WebSocket message
                    final message = {
                      'type': 'file',
                      'recipientId': widget.peerId,
                      'fileUrl': fileUrl,
                      'fileName': fileName,
                      'text': '发送了附件: $fileName', // Fallback text
                    };

                    // Send WS message and add locally
                    _sendWebSocketMessage(
                      message,
                      '附件: $fileName', // Display text in chat bubble
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
                Navigator.of(context).pop(); // Close dialog
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
      ScaffoldMessenger.of(context)
          .removeCurrentSnackBar(); // Remove info snackbar if present
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // --- Make sure these are also present ---
  void _showErrorSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context)
          .removeCurrentSnackBar(); // Remove info snackbar if present
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Placeholder for common phrases
  void _handleCommonPhrases() {
    // --- Mock Implementation ---
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择常用语'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('您好，我对这个职位很感兴趣'),
                  onTap: () {
                    Navigator.pop(context);
                    _controller.text = '您好，我对这个职位很感兴趣';
                    _sendMessage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('请问什么时候可以面试？'),
                  onTap: () {
                    Navigator.pop(context);
                    _controller.text = '请问什么时候可以面试？';
                    _sendMessage();
                  },
                ),
                // Add more phrases
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'))
          ],
        );
      },
    );
    // --- End Mock ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${widget.peerName} 聊天'),
      ),
      body: Column(
        children: [
          // --- Message List ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Assign controller
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Assuming ChatMessage is a StatelessWidget using ChatBubble
                return _messages[index];
              },
            ),
          ),
          // --- Input Area ---
          SafeArea(
            // Prevent input area from overlapping with system UI (like home bar)
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
                // Align items nicely if text field grows
                children: [
                  // Attachment Button (Placeholder)
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.attach_file),
                    onPressed: _isLoadingFiles  ? null : _handleAttachment,
                    tooltip: '发送附件',
                  ),
                  // Common Phrases Button (Placeholder)
                  IconButton(
                    icon: const Icon(Icons.message_outlined), // Different icon?
                    onPressed: _handleCommonPhrases,
                    tooltip: '常用语',
                  ),
                  // Text Input Field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        border: InputBorder.none, // Cleaner look in a container
                        filled: false,
                      ),
                      textInputAction: TextInputAction.send,
                      // Show send button on keyboard
                      onSubmitted: (_) => _sendMessage(),
                      // Send on keyboard send press
                      minLines: 1,
                      maxLines: 5,
                      // Allow multi-line input
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  // Send Button
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    tooltip: '发送',
                    // Disable button if not connected or text is empty? (Optional)
                    // color: _controller.text.isNotEmpty && _channel != null
                    //        ? Theme.of(context).primaryColor
                    //        : Colors.grey,
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

  // --- ADD THESE LINES ---
  final bool isFile; // Indicates if it's a file message
  final String? fileName; // Name of the file (nullable)
  final String? fileUrl; // URL to access the file (nullable)
  // --- END OF ADDED LINES ---

  const ChatMessage({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.avatarUrl,
    // --- ADD THESE PARAMETERS TO THE CONSTRUCTOR ---
    this.isFile = false, // Default to false if not provided
    this.fileName, // Optional parameter
    this.fileUrl, // Optional parameter
    // --- END OF ADDED PARAMETERS ---
  });

  // Helper to launch URL
  Future<void> _launchFileUrl() async {
    if (fileUrl != null) {
      final Uri uri = Uri.parse(fileUrl!);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not launch $fileUrl');
        // Optionally show a snackbar to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If it's a file message, render it differently
    if (isFile) {
      // Check the isFile flag
      return ChatBubble(
        // Assuming ChatBubble is updated for 'child' or handles file display
        isSender: isMe,
        avatarUrl: avatarUrl,
        // Custom child for file display
        message: '',
        child: InkWell(
          onTap: _launchFileUrl, // Make it tappable
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
      // Original rendering for text messages
      return ChatBubble(
        // Assuming ChatBubble takes 'message'
        message: text,
        isSender: isMe,
        avatarUrl: avatarUrl,
      );
    }
  }
}

class WebSocketStatus {
  static const int normalClosure = 1000;
// Add other codes as needed
}
