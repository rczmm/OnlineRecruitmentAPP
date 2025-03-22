import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // 导入 WebSocket 包
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 导入安全存储包
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String peerName; // 对方的用户名
  final String id; // 当前用户的用户名

  const ChatScreen({super.key, required this.peerName, required this.id});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = []; // 存储聊天消息
  late WebSocketChannel _channel;
  String userAvatarUrl = "https://example.com/avatar.jpg"; // 用户的头像URL
  String? myUserId;
  final _storage = FlutterSecureStorage(); // 安全存储实例

  @override
  void initState() {
    super.initState();
    _getUserIdAndConnect();
  }
  
  // 从安全存储中获取userId并连接WebSocket
  Future<void> _getUserIdAndConnect() async {
    // 尝试从安全存储中读取userId
    myUserId = await _storage.read(key: 'userId');
    
    // 获取认证令牌
    String? authToken = await _storage.read(key: 'authToken');
    
    // 如果userId为空，使用默认值或显示错误
    if (myUserId == null || myUserId!.isEmpty) {
      print('警告: 未找到用户ID，使用默认值');
      myUserId = "guest_user"; // 使用访客用户ID作为后备
    }
    
    // 尝试连接WebSocket服务器
    _connectWebSocket(authToken);
  }
  
  // WebSocket连接方法
  void _connectWebSocket([String? authToken]) {
    try {
      // 构建WebSocket URL，添加token参数
      String wsUrl = 'ws://127.0.0.1:8088/chat?userId=$myUserId';
      
      // 如果有认证令牌，添加到URL中
      if (authToken != null && authToken.isNotEmpty) {
        wsUrl += '&token=$authToken';
      }
      
      // 连接 WebSocket 服务器
      // 使用IP地址替代localhost，因为在某些环境下localhost可能无法解析
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // 监听服务器发送的消息
      _channel.stream.listen(
        (message) {
          try {
            print('Received message: $message');
            final decodedMessage = jsonDecode(message);
            final senderId = decodedMessage['senderId'];
            final text = decodedMessage['text'];

            setState(() {
              _messages.add(ChatMessage(
                sender: senderId == myUserId ? '我' : senderId,
                // Display '我' for your own messages echoed back
                text: text,
                isMe: senderId == myUserId,
                avatarUrl: userAvatarUrl, 
              ));
            });
          } catch (e) {
            print('Error decoding message: $e');
            print('Raw message: $message');
            // 显示错误消息给用户
            _showErrorSnackBar('消息解析错误，请稍后重试');
          }
        },
        onError: (error) {
          print('WebSocket错误: $error');
          _showErrorSnackBar('聊天连接错误，正在尝试重新连接...');
          // 尝试重新连接
          Future.delayed(const Duration(seconds: 3), () {
            _connectWebSocket();
          });
        },
        onDone: () {
          print('WebSocket连接已关闭');
          // 如果连接意外关闭，尝试重新连接
          _showErrorSnackBar('聊天连接已断开，正在尝试重新连接...');
          Future.delayed(const Duration(seconds: 3), () {
            _connectWebSocket();
          });
        },
      );
    } catch (e) {
      print('WebSocket连接失败: $e');
      _showErrorSnackBar('无法连接到聊天服务器，请检查网络连接或稍后重试');
      // 延迟后尝试重新连接
      Future.delayed(const Duration(seconds: 5), () {
        _connectWebSocket();
      });
    }
  }
  
  // 显示错误提示
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _channel.sink.close(); // 关闭 WebSocket 连接
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {
        'recipientId': widget.id, // The user you are chatting with
        'text': _controller.text,
      };
      final jsonMessage = jsonEncode(message);
      _channel.sink.add(jsonMessage); // Send JSON message to the server
      setState(() {
        _messages.add(ChatMessage(
          sender: '我',
          text: _controller.text,
          isMe: true,
          avatarUrl: userAvatarUrl,
        ));
        _controller.clear();
      });
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('选择附件简历'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.description),
                                      title: const Text('我的简历.pdf'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _messages.add(ChatMessage(
                                            sender: '我',
                                            text: '[附件简历] 我的简历.pdf',
                                            isMe: true,
                                            avatarUrl: userAvatarUrl,
                                          ));
                                        });
                                        _channel.sink.add('[附件简历] 我的简历.pdf');
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.description),
                                      title: const Text('英文简历.pdf'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _messages.add(ChatMessage(
                                            sender: '我',
                                            text: '[附件简历] 英文简历.pdf',
                                            isMe: true,
                                            avatarUrl: userAvatarUrl,
                                          ));
                                        });
                                        _channel.sink.add('[附件简历] 英文简历.pdf');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('取消'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: '输入消息...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
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
                                    ListTile(
                                      leading: const Icon(Icons.message),
                                      title: const Text('好的，谢谢您'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _controller.text = '好的，谢谢您';
                                        _sendMessage();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('取消'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
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
  final String avatarUrl; // Add avatarUrl

  const ChatMessage({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.avatarUrl, // Add avatarUrl to constructor
  });

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      message: text,
      isSender: isMe,
      avatarUrl: avatarUrl,
    );
  }
}
