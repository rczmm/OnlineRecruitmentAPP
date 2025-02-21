import 'package:flutter/material.dart';

class StatusCounter extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback? onTap;

  const StatusCounter({
    super.key, 
    required this.label, 
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          Text(label),
        ],
      ),
    );
  }
}
