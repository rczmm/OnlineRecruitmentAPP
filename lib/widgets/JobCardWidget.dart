// 职位卡片 Widget
import 'package:flutter/material.dart';

class JobCardWidget extends StatelessWidget {
  final String title;
  final String company;

  const JobCardWidget({super.key, required this.title, required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(company),
      ),
    );
  }
}
