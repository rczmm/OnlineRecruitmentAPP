import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String avatarUrl;
  final Widget? child; // Allow custom content like the file widget
  // final DateTime? timestamp; // Optional: Add timestamp display

  const ChatBubble({
    super.key,
    required this.isSender,
    required this.avatarUrl,
    this.message = '', // Make message optional if child is provided
    this.child,
    // this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isSender ? Theme.of(context).primaryColor : Colors.grey[200];
    final textColor = isSender ? Colors.white : Colors.black87;
    final radius = BorderRadius.circular(12);

    Widget messageContent = child ?? Text(message, style: TextStyle(color: textColor));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible( // Ensures bubble doesn't overflow
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7), // Max width
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: radius.copyWith(
                      bottomLeft: isSender ? radius.bottomLeft : Radius.zero,
                      bottomRight: isSender ? Radius.zero : radius.bottomRight,
                    ),
                  ),
                  child: messageContent,
                ),
                // Optional: Add timestamp below the bubble
                // if (timestamp != null)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 4.0),
                //     child: Text(
                //       // Format timestamp nicely
                //       '${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}',
                //       style: TextStyle(fontSize: 10, color: Colors.grey),
                //     ),
                //   ),
              ],
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }
}