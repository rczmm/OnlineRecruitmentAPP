import 'package:flutter/material.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class InterviewListScreen extends StatelessWidget {
  const InterviewListScreen({super.key});

  // 模拟待面试职位数据
  List<Job> _getInterviewJobs() {
    return [
       Job(
          id: '1',
          title: '高级Flutter开发工程师',
          company: '科技有限公司',
          companySize: '500-1000人',
          salary: '25K-35K',
          location: '上海',
          description: '负责公司核心业务的Flutter应用开发',
          requirements: ['本科及以上学历', '3年以上Flutter开发经验'],
          tags: ['Flutter', '移动端开发', '高薪'],
          status: '待查看',
          date: '2024-01-15',
          hrName: "张女士",
          workExperience: "3年",
          education: "本科",
          benefits: ["五险一金", "带薪年假", "节日福利"]),
      // 可以添加更多待面试职位
    ];
  }

  @override
  Widget build(BuildContext context) {
    final interviewJobs = _getInterviewJobs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('待面试职位'),
      ),
      body: ListView.builder(
        itemCount: interviewJobs.length,
        itemBuilder: (context, index) {
          final job = interviewJobs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: JobCard(
              job: job,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(job: job),
                  ),
                );
              },
              showInterviewTime: true, // 显示面试时间
            ),
          );
        },
      ),
    );
  }
}