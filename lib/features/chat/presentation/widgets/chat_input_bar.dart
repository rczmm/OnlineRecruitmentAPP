import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onAttachFile;
  final VoidCallback onShowCommonPhrases;
  final bool isAttachmentLoading;
  final bool isUploading;
  final TextEditingController controller;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    required this.onAttachFile,
    required this.onShowCommonPhrases,
    this.isAttachmentLoading = false,
    this.isUploading = false,
    required this.controller,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  @override
  void initState() {
    super.initState();
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      widget.controller.clear();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Ensure input bar doesn't overlap system UI
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 4,
              color: Colors.black.withAlpha(7),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
          children: [
            // Attach File Button
            IconButton(
              icon: widget.isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.attach_file),
              onPressed: (widget.isAttachmentLoading || widget.isUploading)
                  ? null
                  : widget.onAttachFile,
              tooltip: '发送附件',
            ),
            // Common Phrases Button
            IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: widget.onShowCommonPhrases,
              tooltip: '常用语',
            ),
            // Text Input Field
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                  filled: false,
                  // Don't fill background within the input bar container
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 10), // Adjust padding
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                minLines: 1,
                maxLines: 5,
                // Allow multi-line input
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            // Send Button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSend,
              tooltip: '发送',
            ),
          ],
        ),
      ),
    );
  }
}
