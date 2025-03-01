import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';
import 'search_screen.dart';

class JobListContainer extends StatefulWidget {
  final List<Job> Function() onLoadMore;

  const JobListContainer({super.key, required this.onLoadMore});

  @override
  State<JobListContainer> createState() => _JobListContainerState();
}

class _JobListContainerState extends State<JobListContainer>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<String> _keywords = [
    '技术开发',
    '产品运营',
    '设计创意',
    '市场营销',
    '人力资源',
    '金融财务',
    '教育培训',
    '医疗健康'
  ];
  String _errorMessage = '';
  String _currentMainTab = '';
  String _currentSubTab = '推荐';
  late TabController _mainTabController =
      TabController(length: _keywords.length, vsync: this);
  late TabController _subTabController = TabController(length: 3, vsync: this);
  List<JobListView> _jobListViews = [];

  @override
  void initState() {
    super.initState();
    _fetchKeywords();
    // 初始化三个 JobListView，对应推荐、附近、最新三个标签页
    _jobListViews = List.generate(
        3,
        (index) => JobListView(
              key: GlobalKey<_JobListViewState>(
                  debugLabel: 'JobListView_$index'),
              onLoadMore: widget.onLoadMore,
            ));
  }

  Future<void> _fetchKeywords() async {
    setState(() {
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
        if (_keywords.isNotEmpty) {
          _currentMainTab = _keywords[0];
        }
      }
    } on DioException catch (e) {
      _errorMessage = '请求异常 ${e.message}';
      if (e.response != null) {
        _errorMessage = '请求异常 ${e.response!.statusCode} ${e.response!.data}';
      }
      // 在请求失败时设置默认的关键词数据
      _keywords = [
        '技术开发',
        '产品运营',
        '设计创意',
        '市场营销',
        '人力资源',
        '金融财务',
        '教育培训',
        '医疗健康'
      ];
      _mainTabController = TabController(length: _keywords.length, vsync: this);
      if (_keywords.isNotEmpty) {
        _currentMainTab = _keywords[0];
      }
    }
  }

  void _onSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: query),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索职位、公司或技能标签',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: _onSearch,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _mainTabController,
                isScrollable: true,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                tabs: _keywords
                    .map((keyword) => Tab(
                          text: keyword,
                          height: 44,
                        ))
                    .toList(),
                onTap: (index) {
                  setState(() {
                    _currentMainTab = _keywords[index];
                  });
                  _subTabController.index = 0;
                  _currentSubTab = '推荐';
                  // 刷新当前标签页的职位列表
                  if (_subTabController.index >= 0 &&
                      _subTabController.index < _jobListViews.length) {
                    final state = (_jobListViews[_subTabController.index].key
                            as GlobalKey<_JobListViewState>)
                        .currentState;
                    state?.refreshJobList();
                  }
                },
              ),
              TabBar(
                controller: _subTabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: '推荐', height: 40),
                  Tab(text: '附近', height: 40),
                  Tab(text: '最新', height: 40),
                ],
                onTap: (index) {
                  setState(() {
                    _currentSubTab = ['推荐', '附近', '最新'][index];
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: _jobListViews,
          ),
        ),
      ],
    );
  }
}

class JobListView extends StatefulWidget {
  final List<Job> Function() onLoadMore;

  const JobListView({super.key, required this.onLoadMore});

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView> {
  final ScrollController _scrollController = ScrollController();
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newJobs = widget.onLoadMore();
      setState(() {
        _jobs.addAll(newJobs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载数据失败：$e';
        _isLoading = false;
      });
    }
  }

  void refreshJobList() {
    setState(() {
      _jobs.clear();
    });
    _loadJobs();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadJobs();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadJobs(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _jobs.clear();
        await _loadJobs();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _jobs.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _jobs.length) {
            return JobCard(job: _jobs[index]);
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

