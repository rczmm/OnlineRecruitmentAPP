import 'package:flutter/material.dart';
import '../models/job.dart';
import 'home_screen.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  List<Job> _loadMoreJobs() {
    // 这里可以调用API获取更多职位数据
    // 暂时返回空列表，实际数据会由JobList中的_generateSampleJobs生成
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return JobList(onLoadMore: _loadMoreJobs);
  }
}