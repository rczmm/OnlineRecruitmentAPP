import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final DateTime time;
  final String? avatarUrl;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.avatarUrl,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dt.year, dt.month, dt.day);

    if (messageDate == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDate).inDays == 1) {
      return '昨天';
    } else {
      return '${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        backgroundColor: colorScheme.secondaryContainer, // Use theme color
        child: !hasAvatar
            ? Icon(Icons.person_outline,
                color: colorScheme.onSecondaryContainer, size: 24)
            : null,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      ),
      trailing: Text(
        _formatTime(time),
        style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }
}
