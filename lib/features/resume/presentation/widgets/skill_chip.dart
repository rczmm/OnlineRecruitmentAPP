import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String skill;
  final bool isEditing;
  final VoidCallback? onDelete;

  const SkillChip({
    super.key,
    required this.skill,
    this.isEditing = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(skill),
      deleteIcon: isEditing ? const Icon(Icons.cancel, size: 18) : null,
      onDeleted: isEditing ? onDelete : null,
    );
  }
}