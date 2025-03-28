import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/jobs/data/models/job_model.dart';
import '../screens/job_detail_screen1.dart';

class ApplicationHistoryScreen extends StatefulWidget {
  final int initialTabIndex; // 0 表示已投递，1 表示沟通过

  const ApplicationHistoryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ApplicationHistoryScreen> createState() => _ApplicationHistoryScreenState();
}

class _ApplicationHistoryScreenState extends State<ApplicationHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 模拟数据
  final List<Job> deliveredJobs = [
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
      benefits: ["五险一金", "带薪年假", "节日福利"],
      isFavorite: true,
    ),
    Job(
      id: '2',
      title: 'Flutter开发工程师',
      company: '互联网科技公司',
      companySize: '1000-2000人',
      salary: '20K-30K',
      location: '北京',
      description: '参与公司移动端产品的开发和维护',
      requirements: ['本科及以上学历', '2年以上Flutter开发经验'],
      tags: ['Flutter', '移动端开发'],
      status: '已查看',
      date: '2024-01-14',
         hrName: "张女士",
      workExperience: "3年",
      education: "本科",
      benefits: ["五险一金", "带薪年假", "节日福利"],
      isFavorite: true,
    ),
  ];

  final List<Job> communicatedJobs = [
    Job(
      id: '3',
      title: '资深Flutter开发工程师',
      company: '科技股份有限公司',
      companySize: '1000-2000人',
      salary: '30K-45K',
      location: '上海',
      description: '负责团队Flutter应用开发和架构设计',
      requirements: ['本科及以上学历', '5年以上Flutter开发经验'],
      tags: ['Flutter', '架构设计', '高薪'],
      status: '待回复',
      date: '2024-01-16',
      hrName: '李经理',
      workExperience: '5年',
      education: '本科',
      benefits: ['五险一金', '年终奖', '股票期权'],
      isFavorite: true,
    ),
    Job(
      id: '4',
      title: '移动端开发工程师',
      company: '网络科技有限公司',
      companySize: '500-1000人',
      salary: '20K-35K',
      location: '北京',
      description: '负责公司移动端产品开发',
      requirements: ['本科及以上学历', '3年以上移动端开发经验'],
      tags: ['Flutter', 'Android', 'iOS'],
      status: '已回复',
      date: '2024-01-13',
      hrName: '王HR',
      workExperience: '3年',
      education: '本科',
      benefits: ['五险一金', '弹性工作', '免费三餐'],
      isFavorite: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投递记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '已投递'),
            Tab(text: '沟通过'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 已投递列表
          ListView.builder(
            itemCount: deliveredJobs.length,
            itemBuilder: (context, index) {
              final job = deliveredJobs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(job.title),
                  subtitle: Row(
                    children: [
                      Text(job.company),
                      const SizedBox(width: 10),
                      Text(
                        job.status,
                        style: TextStyle(
                          color: job.status == '已查看' ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(job.date),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // 沟通过列表
          ListView.builder(
            itemCount: communicatedJobs.length,
            itemBuilder: (context, index) {
              final job = communicatedJobs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(job.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.company),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              job.status,
                              style: TextStyle(color: Colors.green[800]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(job.date),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}