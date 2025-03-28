import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/jobs/data/models/job_model.dart';
import 'package:zhaopingapp/screens/job_detail_screen1.dart';

class CollectScreen extends StatefulWidget {
  const CollectScreen({super.key});

  @override
  State<CollectScreen> createState() => _CollectScreenState();
}

class _CollectScreenState extends State<CollectScreen> {
// 模拟收藏的职位数据列表
  final List<Map<String, String>> _collectedJobs = [
    {
      'jobTitle': 'Java 后端工程师',
      'company': '某某科技有限公司',
      'location': '北京',
      'salary': '15k-25k',
    },
    {
      'jobTitle': 'Flutter 工程师',
      'company': 'XX创新有限公司',
      'location': '上海',
      'salary': '18k-30k',
    },
    {
      'jobTitle': '产品经理',
      'company': 'YY互联网公司',
      'location': '深圳',
      'salary': '20k-35k',
    },
// 可以添加更多模拟数据
  ];

  void _uncollectJob(int index) {
    setState(() {
      _collectedJobs.removeAt(index);
// 在实际应用中，你还需要调用 API 或更新本地数据库来取消收藏
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消收藏')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Job jobd = Job(
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
      hrUserId: '1001',
      hrName: "张女士",
      workExperience: "3年",
      education: "本科",
      benefits: ["五险一金", "带薪年假", "节日福利"],
      isFavorite: true,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏'),
      ),
      body: _collectedJobs.isEmpty
          ? const Center(
              child: Text('你还没有收藏任何职位', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: _collectedJobs.length,
              itemBuilder: (context, index) {
                final job = _collectedJobs[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['jobTitle']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job['company']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              job['location']!,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.attach_money,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              job['salary']!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailScreen(
                                      job: jobd,
                                    ),
                                  ),
                                )
                              },
                              child: const Text('查看详情'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _uncollectJob(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('取消收藏'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
