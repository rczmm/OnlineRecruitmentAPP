import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';
import 'package:zhaopingapp/widgets/chat_bubble.dart'; // Your chat bubble widget

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageWidget({super.key, required this.message});

  Future<void> _launchFileUrl(BuildContext context) async {
    if (message.fileUrl != null) {
      final Uri uri = Uri.parse(message.fileUrl!);
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $uri');
          _showErrorSnackbar(context, '无法打开文件链接');
        }
      } catch (e) {
        debugPrint('Error launching URL: $e');
        _showErrorSnackbar(context, '打开链接时出错');
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.isFile) {
      // Build file message bubble
      return ChatBubble(
        isSender: message.isMe,
        avatarUrl: message.avatarUrl,
        // timestamp: message.timestamp, // Pass timestamp if ChatBubble supports it
        child: InkWell(
          onTap: () => _launchFileUrl(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Reduced padding inside InkWell
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, size: 18, color: message.isMe ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.fileName ?? '附件',
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent long filenames from breaking layout
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Build regular text message bubble
      return ChatBubble(
        message: message.text,
        isSender: message.isMe,
        avatarUrl: message.avatarUrl,
        // timestamp: message.timestamp, // Pass timestamp if ChatBubble supports it
      );
    }
  }
}