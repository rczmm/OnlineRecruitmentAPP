import 'package:flutter/material.dart';
import '../models/job.dart';
import '../screens/job_detail_screen.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool showInterviewTime;
  final String? interviewTime;

  const JobCard(
      {super.key,
      required this.job,
      this.onTap,
      this.showInterviewTime = false,
      this.interviewTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
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
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.salary,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    job.company,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: job.tags
                    .map((tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF81C784),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF81C784),
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HR ${job.hrName}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: Color(0xFF81C784)),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              if (showInterviewTime && interviewTime != null) ...[
                // 只在需要显示面试时间且有面试时间时显示
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Text(
                      '面试时间：$interviewTime',
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                )
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
