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

  String _myUserId = "unknown_user";
  final String _myAvatarUrl =
      "https://via.placeholder.com/150/0000FF/FFFFFF?text=Me"; // Replace with actual
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
        "https://via.placeholder.com/150/FF0000/FFFFFF?text=Peer"; // Default Peer Avatar
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
    try {
      String? storedUserId = await _storage.read(key: 'userId');
      String? authToken = await _storage.read(key: 'authToken');

      if (storedUserId == null || storedUserId.isEmpty) {
        debugPrint('Warning: userId not found. Using default.');
        _myUserId = "guest_${DateTime.now().millisecondsSinceEpoch}";
        if (mounted) SnackbarUtil.showError(context, "无法加载用户信息");
        return;
      } else {
        _myUserId = storedUserId;
      }

      debugPrint('My User ID: $_myUserId');
      debugPrint('Connecting to chat with Peer ID: ${widget.peerId}');

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
        _connectionStatus = ConnectionStatus.error;
      });
    }
  }

  void _onMessageReceived(ChatMessageModel message) {
    // Ensure messages are added only once and list is updated
    if (mounted && !_messages.any((m) => m.id == message.id)) {
      // Check for duplicate IDs if provided
      setState(() {
        _messages.add(message);
        // Optionally sort messages by timestamp if order isn't guaranteed
        // _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
      // Scrolling is handled by MessageListView's didUpdateWidget
    }
  }

  void _onStatusChanged(ConnectionStatus status) {
    if (mounted) {
      setState(() {
        _connectionStatus = status;
      });
      // Show feedback based on status
      switch (status) {
        case ConnectionStatus.connecting:
          // SnackbarUtil.showInfo(context, "连接中...", showProgress: true, duration: Duration(minutes: 1));
          break;
        case ConnectionStatus.connected:
          SnackbarUtil.showSuccess(context, "已连接");
          break;
        case ConnectionStatus.disconnected:
          // Might be intentional, don't show error unless it was unexpected
          // SnackbarUtil.showInfo(context, "已断开连接");
          break;
        case ConnectionStatus.error:
          SnackbarUtil.showError(context, "连接错误，尝试重连中...");
          break;
      }
    }
  }

  void _handleSendMessage(String text) {
    final tempId = UniqueKey().toString(); // Temporary ID for optimistic update
    final optimisticMessage = ChatMessageModel(
      id: tempId,
      senderId: _myUserId,
      senderName: '我',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      avatarUrl: _myAvatarUrl,
    );

    // Optimistic UI update
    setState(() {
      _messages.add(optimisticMessage);
    });
    // Scrolling handled by MessageListView

    try {
      _chatService.sendMessage(widget.peerId, text);
      // Optionally: Wait for confirmation from backend to update message status (e.g., sent -> delivered)
    } catch (e) {
      debugPrint("Error sending message: $e");
      if (mounted) SnackbarUtil.showError(context, "消息发送失败");
      // Optionally remove the optimistic message or mark it as failed
      setState(() {
        _messages.removeWhere((m) => m.id == tempId);
        // Or: update message state to 'failed'
      });
    }
  }

  Future<void> _fetchUserFiles() async {
    if (_isLoadingFiles) return;

    setState(() {
      _isLoadingFiles = true;
    });
    // Optionally disable attach button in input bar:
    // _chatInputBarKey.currentState?.setIsAttachmentLoading(true);

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
        // _chatInputBarKey.currentState?.setIsAttachmentLoading(false);
      }
    }
  }

  Future<void> _handleAttachment() async {
    // Fetch files if list is empty and not already loading
    if (_userFiles.isEmpty && !_isLoadingFiles) {
      await _fetchUserFiles();
      // If still empty after fetching (and not loading), show message
      if (mounted && _userFiles.isEmpty && !_isLoadingFiles) {
        SnackbarUtil.showInfo(context, "没有可用的附件文件。");
        return;
      }
    } else if (_isLoadingFiles) {
      SnackbarUtil.showInfo(context, "正在加载文件列表...", showProgress: true);
      return;
    }

    // If files are available, show selection dialog
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
            height: MediaQuery.of(context).size.height *
                0.4, // Adjust size as needed
            child: _userFiles
                    .isEmpty // Should not happen if called correctly, but good fallback
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
                          Navigator.of(context).pop(); // Close dialog
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
      // Fetch phrases directly here or have a dedicated provider/manager
      final phrases = await _apiService.fetchCommonPhrases(_myUserId);

      if (!mounted) return; // Check if widget is still mounted after async call

      if (phrases.isEmpty) {
        SnackbarUtil.showInfo(context, '没有可用的常用语。');
        // Optionally navigate to manage phrases page
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CommonPhrasesPage()));
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
                    _textEditingController.text = phrase.text;
                    _handleSendMessage(phrase.text);
                    _textEditingController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: _textEditingController.text.length));
                    Navigator.pop(dialogContext);
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
        // Optionally show connection status in AppBar
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
