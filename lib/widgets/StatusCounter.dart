import 'package:flutter/material.dart';

class StatusCounter extends StatelessWidget {
  final String label;
  final int count;

  const StatusCounter({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
