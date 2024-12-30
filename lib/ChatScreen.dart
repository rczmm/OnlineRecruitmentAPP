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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '输入消息...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
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