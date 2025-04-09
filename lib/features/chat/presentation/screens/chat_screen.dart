import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/services/api_service.dart';
import 'package:zhaopingapp/core/utils/snackbar_util.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';
import 'package:zhaopingapp/features/chat/data/services/chat_service.dart';
import 'package:zhaopingapp/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:zhaopingapp/features/chat/presentation/widgets/message_list_view.dart';

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
  final ChatService _chatService = ChatService();
  final ApiService _apiService = ApiService();

  final List<ChatMessageModel> _messages = [];
  List<UserFile> _userFiles = [];
  bool _isLoadingFiles = false;
  bool _isLoadingHistory = true;

  String _myUserId = "unknown_user";
  final String _myAvatarUrl =
      "https://i0.hdslb.com/bfs/archive/aa77ca3d1f12e590d8458274868e13f21d620865.jpg"; // Replace with actual
  late String _peerAvatarUrl;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _peerAvatarUrl = widget.peerAvatarUrl ??
        "https://via.placeholder.com/150/FF0000/FFFFFF?text=Peer";
    _setupListeners();
    _initializeChat();
  }

  void _setupListeners() {
    _messageSubscription =
        _chatService.messageStream.listen(_onMessageReceived, onError: (error) {
      debugPrint("Error in message stream: $error");
    });

    _statusSubscription =
        _chatService.statusStream.listen(_onStatusChanged, onError: (error) {
      debugPrint("Error in status stream: $error");
    });
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoadingHistory = true; // Start loading history
      _connectionStatus =
          ConnectionStatus.connecting; // Show connecting status early
    });

    try {
      String? storedUserId = await _storage.read(key: 'userId');
      String? authToken = await _storage.read(key: 'authToken');

      if (storedUserId == null || storedUserId.isEmpty) {
        debugPrint('Warning: userId not found. Using default.');
        _myUserId = "guest_${DateTime.now().millisecondsSinceEpoch}";
        if (mounted) SnackbarUtil.showError(context, "无法加载用户信息");
        setState(() {
          _isLoadingHistory = false;
          _connectionStatus = ConnectionStatus.error;
        });
        return;
      } else {
        _myUserId = storedUserId;
      }

      debugPrint('My User ID: $_myUserId');
      debugPrint('Connecting to chat with Peer ID: ${widget.peerId}');

      await _loadHistory();

      _chatService.connect(
        userId: _myUserId,
        token: authToken,
        peerId: widget.peerId,
        peerName: widget.peerName,
        myAvatar: _myAvatarUrl,
        peerAvatar: _peerAvatarUrl,
      );
    } catch (e) {
      debugPrint("Error reading from secure storage or connecting: $e");
      if (mounted) SnackbarUtil.showError(context, "初始化聊天失败: $e");
      setState(() {
        _isLoadingHistory = false;
        _connectionStatus = ConnectionStatus.error;
      });
    }
  }

  void _onMessageReceived(ChatMessageModel message) {
    if (mounted && !_messages.any((m) => m.id == message.id)) {
      setState(() {
        _messages.add(message);
      });
    }
  }

  void _onStatusChanged(ConnectionStatus status) {
    if (mounted) {
      setState(() {
        _connectionStatus = status;
      });
      switch (status) {
        case ConnectionStatus.connecting:
          break;
        case ConnectionStatus.connected:
          SnackbarUtil.showSuccess(context, "已连接");
          break;
        case ConnectionStatus.disconnected:
          break;
        case ConnectionStatus.error:
          SnackbarUtil.showError(context, "连接错误，尝试重连中...");
          break;
      }
    }
  }

  void _handleSendMessage(String text) {
    final tempId = UniqueKey().toString();
    final optimisticMessage = ChatMessageModel(
      id: tempId,
      senderId: _myUserId,
      senderName: '我',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      avatarUrl: _myAvatarUrl,
    );

    setState(() {
      _messages.add(optimisticMessage);
    });

    try {
      debugPrint("Sending file message: ${widget.peerId}");
      _chatService.sendMessage(widget.peerId, text);
    } catch (e) {
      debugPrint("Error sending message: $e");
      if (mounted) SnackbarUtil.showError(context, "消息发送失败");
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });
    }
  }

  Future<void> _fetchUserFiles() async {
    if (_isLoadingFiles) return;

    setState(() {
      _isLoadingFiles = true;
    });

    try {
      final files = await _apiService.fetchUserFiles();
      if (mounted) {
        setState(() {
          _userFiles = files;
        });
      }
    } catch (e) {
      debugPrint("Error fetching files: $e");
      if (mounted) SnackbarUtil.showError(context, "加载附件列表失败: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
      }
    }
  }

  Future<void> _handleAttachment() async {
    if (_userFiles.isEmpty && !_isLoadingFiles) {
      await _fetchUserFiles();
      if (mounted && _userFiles.isEmpty && !_isLoadingFiles) {
        SnackbarUtil.showInfo(context, "没有可用的附件文件。");
        return;
      }
    } else if (_isLoadingFiles) {
      SnackbarUtil.showInfo(context, "正在加载文件列表...", showProgress: true);
      return;
    }

    if (mounted && _userFiles.isNotEmpty) {
      _showFileSelectionDialog();
    }
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
                      return ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(file.fileName),
                        onTap: () {
                          Navigator.of(context).pop();
                          _sendFileMessage(file);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void _sendFileMessage(UserFile file) {
    final tempId = UniqueKey().toString();
    final optimisticMessage = ChatMessageModel(
      id: tempId,
      senderId: _myUserId,
      senderName: '我',
      text: '附件: ${file.fileName}',
      // Display text for the file message
      timestamp: DateTime.now(),
      isMe: true,
      avatarUrl: _myAvatarUrl,
      isFile: true,
      fileName: file.fileName,
      fileUrl: file.fileUrl,
    );

    // Optimistic UI update
    setState(() {
      _messages.add(optimisticMessage);
    });

    try {
      _chatService.sendFileMessage(
        recipientId: widget.peerId,
        fileName: file.fileName,
        fileUrl: file.fileUrl,
      );
      if (mounted) SnackbarUtil.showSuccess(context, "已发送附件: ${file.fileName}");
    } catch (e) {
      debugPrint("Error sending file message: $e");
      if (mounted) SnackbarUtil.showError(context, "附件发送失败");
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
      });
    }
  }

  Future<void> _handleShowCommonPhrases() async {
    if (_myUserId == "unknown_user") {
      SnackbarUtil.showError(context, '无法加载常用语：用户信息不完整。');
      return;
    }

    try {
      final phrases = await _apiService.fetchCommonPhrases(_myUserId);

      if (!mounted) return;

      if (phrases.isEmpty) {
        SnackbarUtil.showInfo(context, '没有可用的常用语。');
        return;
      }

      _showSelectPhraseDialog(phrases);
    } catch (e) {
      debugPrint("Error fetching/showing common phrases: $e");
      if (mounted) SnackbarUtil.showError(context, "加载常用语失败: $e");
    }
  }

  void _showSelectPhraseDialog(List<CommonPhrase> phrases) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('选择常用语'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return ListTile(
                  title: Text(phrase.text),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _textEditingController.text = phrase.text;
                    // 可选：将光标移到文本末尾
                    _textEditingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _textEditingController.text.length));
                  },
                );
              },
            ),
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

  Future<void> _loadHistory() async {
    if (_myUserId == "unknown_user") return; // Don't load if user ID is invalid

    try {
      final historyData = await _apiService.fetchChatHistory(
          sendId: _myUserId, receiveId: widget.peerId);

      final String peerName = widget.peerId;

      debugPrint("History data: $peerName");

      if (!mounted) return;

      final List<ChatMessageModel> historyMessages = historyData.map((data) {
        return ChatMessageModel.fromJson(
          data,
          _myUserId,
          widget.peerName,
          _myAvatarUrl,
          _peerAvatarUrl,
        );
      }).toList();

      setState(() {
        // Prepend history and sort
        _messages.insertAll(0, historyMessages);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _isLoadingHistory = false; // History loading finished
      });

      // Jump to bottom after history is loaded and UI is updated
      _jumpToBottom();
    } catch (e) {
      debugPrint("Error loading chat history: $e");
      if (mounted) SnackbarUtil.showError(context, "加载聊天记录失败: $e");
      setState(() {
        _isLoadingHistory = false; // Stop loading indicator on error
      });
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _chatService.dispose();
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${widget.peerName} 聊天'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _connectionStatus == ConnectionStatus.connected
                  ? Icons.circle
                  : _connectionStatus == ConnectionStatus.connecting
                      ? Icons.sync_problem
                      : Icons.circle_outlined,
              color: _connectionStatus == ConnectionStatus.connected
                  ? Colors.green
                  : _connectionStatus == ConnectionStatus.connecting
                      ? Colors.orange
                      : Colors.red,
              size: 14,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (_isLoadingHistory)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_isLoadingHistory)
            Expanded(
              child: MessageListView(
                messages: _messages,
                scrollController: _scrollController,
              ),
            ),
          ChatInputBar(
            controller: _textEditingController,
            onSendMessage: _handleSendMessage,
            onAttachFile: _handleAttachment,
            onShowCommonPhrases: _handleShowCommonPhrases,
            isAttachmentLoading: _isLoadingFiles,
          ),
        ],
      ),
    );
  }
}
