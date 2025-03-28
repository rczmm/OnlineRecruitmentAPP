import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';
import 'package:zhaopingapp/features/chat/presentation/widgets/chat_message_widget.dart';


class MessageListView extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final ScrollController scrollController;

  const MessageListView({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when new messages are added
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      // Use addPostFrameCallback to ensure the list view has rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check again if mounted before scrolling
        if (mounted && widget.scrollController.hasClients) {
          widget.scrollController.animateTo(
            widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use ListView.builder for performance with many messages
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        // Add keys if needed for more complex list updates
        return ChatMessageWidget(message: message);
      },
    );
  }
}