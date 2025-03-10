import 'package:flutter/material.dart';
import '../models/job.dart';
import '../screens/job_detail_screen.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool showInterviewTime;
  final String? interviewTime;
  const JobCard({super.key, required this.job, this.onTap, this.showInterviewTime = false, this.interviewTime});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title,
                  style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('薪资：${job.salary}'),
              Text('公司：${job.company} (${job.companySize})'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: job.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 8),
                  Text('HR：${job.hrName}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('地点：${job.location}'),
              if (showInterviewTime && interviewTime != null) ...[  // 只在需要显示面试时间且有面试时间时显示
                const SizedBox(height: 8),
                Text('面试时间：$interviewTime', style: const TextStyle(color: Colors.blue)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class JobList extends StatelessWidget {
  final List<Job> jobs;
  const JobList({super.key, required this.jobs});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return JobCard(job: jobs[index]);
      },
    );
  }
}