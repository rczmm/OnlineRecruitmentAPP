import 'package:flutter/material.dart';

class ListSectionHeader extends StatelessWidget {
  final String title;

  const ListSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.dividerColor.withAlpha(30),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.hintColor,
        ),
      ),
    );
  }
}
