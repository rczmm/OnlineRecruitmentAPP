import 'package:flutter/material.dart';

// 消息气泡组件
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String avatarUrl;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isSender,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSender ? Colors.blueAccent : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isSender ? Radius.circular(12) : Radius.zero,
                bottomRight: isSender ? Radius.zero : Radius.circular(12),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(color: isSender ? Colors.white : Colors.black87),
            ),
          ),
        ),
        if (isSender) CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
      ],
    );
  }
}