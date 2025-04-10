import 'package:flutter/material.dart';

class ListItemCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditing;

  const ListItemCard({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child),
            if (isEditing) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                color: Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }
}