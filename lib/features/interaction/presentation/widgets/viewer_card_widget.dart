import 'package:flutter/material.dart';
import 'package:zhaopingapp/models/viewer_info.dart'; // Adjust path
// Optional: import 'package:intl/intl.dart';

class ViewerCardWidget extends StatelessWidget {
  final ViewerInfo viewer;

  const ViewerCardWidget({super.key, required this.viewer});

  String _formatTimeAgo(DateTime dt) {
    final duration = DateTime.now().difference(dt);
    if (duration.inMinutes < 60) return '${duration.inMinutes}分钟前';
    if (duration.inHours < 24) return '${duration.inHours}小时前';
    return '${duration.inDays}天前';
    // Use timeago package for better formatting
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bool hasAvatar = viewer.avatarUrl != null && viewer.avatarUrl!.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: hasAvatar ? NetworkImage(viewer.avatarUrl!) : null,
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: !hasAvatar ? Icon(Icons.person_outline, color: theme.colorScheme.onSecondaryContainer) : null,
      ),
      title: Text(viewer.name, style: textTheme.titleMedium),
      subtitle: Text(viewer.company, style: textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
      trailing: Text(_formatTimeAgo(viewer.viewedAt), style: textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      onTap: () {
        // TODO: Navigate to viewer's profile or chat
        debugPrint('Tapped on viewer: ${viewer.name}');
      },
    );
  }
}