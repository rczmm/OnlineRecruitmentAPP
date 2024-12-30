import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subTabController;

  List<String> _keywords = []; // 动态关键词列表
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _keywords.length, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _fetchKeywords();
  }

  Future<void> _fetchKeywords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await dio.get("getKeywords");
      // 判断返回数据是否正确
      if (response.statusCode == 200 &&
          response.data['code'] == 200 &&
          response.data['date'] is List) {
        _keywords = response.data['date'].cast<String>();
        _mainTabController =
            TabController(length: _keywords.length, vsync: this);
        _subTabController = TabController(length: 3, vsync: this);
      }
    } on DioException catch (e) {
      _errorMessage = '请求异常 ${e.message}';
      if (e.response != null) {
        _errorMessage = '请求异常 ${e.response!.statusCode} ${e.response!.data}';
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _mainTabController,
          isScrollable: true, // 允许滚动
          tabs: _keywords.map((keyword) => Tab(text: keyword)).toList(),
          onTap: (index) {
            // 当主 Tab 切换时，重置子 Tab 到第一个
            _subTabController.index = 0;
          },
        ),
        TabBar(
          controller: _subTabController,
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '附近'),
            Tab(text: '最新'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              // 推荐
              JobList(jobs: _generateSampleJobs()),
              // 附近
              JobList(jobs: _generateSampleJobs()),
              // 最新
              JobList(jobs: _generateSampleJobs()),
            ],
          ),
        ),
      ],
    );
  }

  // 生成示例数据
  List<Job> _generateSampleJobs() {
    return List.generate(
        10,
        (index) => Job(
            title: 'Java 开发工程师 $index',
            salary: '10k-20k',
            company: 'XX科技有限公司',
            companySize: '100-500人',
            tags: ['Java', 'Spring', 'MySQL'],
            hrName: '李先生',
            location: '深圳市'));
  }
}
