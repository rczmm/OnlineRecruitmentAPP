import 'package:flutter/material.dart';

import '../ChatScreen.dart';

class PendingInterviewScreen extends StatelessWidget {
  const PendingInterviewScreen({super.key});

  // 模拟待面试的数据列表
  final List<Map<String, String>> _pendingInterviewList = const [
    {
      'jobTitle': 'Java 后端工程师',
      'company': '某某科技有限公司',
      'interviewTime': '明天下午 2:00',
      'interviewLocation': '北京市海淀区某大厦',
    },
    {
      'jobTitle': 'Flutter 工程师',
      'company': 'XX创新有限公司',
      'interviewTime': '后天上午 10:30',
      'interviewLocation': '上海市浦东新区',
    },
    {
      'jobTitle': '算法工程师',
      'company': 'YY人工智能研究院',
      'interviewTime': '下周一上午 9:00',
      'interviewLocation': '深圳市南山区',
    },
    // 可以添加更多模拟数据
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待面试'),
      ),
      body: _pendingInterviewList.isEmpty
          ? const Center(
              child: Text('暂无待面试的职位', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: _pendingInterviewList.length,
              itemBuilder: (context, index) {
                final interview = _pendingInterviewList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview['jobTitle']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interview['company']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '面试时间：${interview['interviewTime']!}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            // 可以添加其他状态或标签，例如“待确认”等
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '面试地点：${interview['interviewLocation']!}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // 实现联系面试官的逻辑，跳转到聊天页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      peerName: interview['company']!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('联系面试官'),
                            )
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
