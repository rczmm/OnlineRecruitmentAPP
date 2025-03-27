import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String? message;
  final Widget? child;

  final bool isSender;
  final String avatarUrl;

  const ChatBubble({
    super.key,
    this.message,
    this.child,
    required this.isSender,
    required this.avatarUrl,
  }) : assert(message != null || child != null,
            'Either message or child must be provided.');

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSender ? Theme.of(context).primaryColor : Colors.grey[300];
    final textColor = isSender ? Colors.white : Colors.black87;
    final radius = Radius.circular(12);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                  bottomLeft: isSender ? radius : Radius.zero,
                  bottomRight: isSender ? Radius.zero : radius,
                ),
              ),
              child: child ??
                  SelectableText(
                    message!,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
              // --- MODIFICATION END ---
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
