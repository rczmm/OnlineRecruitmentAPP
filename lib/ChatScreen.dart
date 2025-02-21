import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // 导入 WebSocket 包

class ChatScreen extends StatefulWidget {
  final String peerName; // 对方的用户名

  const ChatScreen({super.key, required this.peerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = []; // 存储聊天消息
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    // 连接 WebSocket 服务器，替换成你的服务器地址
    _channel = WebSocketChannel.connect(Uri.parse('ws://your-websocket-server-url'));

    // 监听服务器发送的消息
    _channel.stream.listen((message) {
      setState(() {
        _messages.add(ChatMessage(
          sender: widget.peerName, // 假设服务器发来的消息是对方的
          text: message,
          isMe: false,
        ));
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(); // 关闭 WebSocket 连接
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text); // 发送消息到服务器
      setState(() {
        _messages.add(ChatMessage(
          sender: '我',
          text: _controller.text,
          isMe: true,
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
            padding: const EdgeInsets.all(8.0),
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

  const ChatMessage({super.key, required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(text),
      ),
    );
  }
}