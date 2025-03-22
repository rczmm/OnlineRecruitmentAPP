import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';
import 'search_screen.dart';

class JobListContainer extends StatefulWidget {
  final Future<List<Job>> Function(String? type, String? tag) onLoadMore;
  final Future<List<Job>> Function(String? type, String? tag) onRefresh;

  const JobListContainer(
      {super.key, required this.onLoadMore, required this.onRefresh});

  @override
  State<JobListContainer> createState() => _JobListContainerState();
}

class _JobListContainerState extends State<JobListContainer>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<String> _keywords = [];
  late TabController _mainTabController;
  late TabController _subTabController;
  final List<GlobalKey<_JobListViewState>> _listViewKeys =
      List.generate(3, (index) => GlobalKey<_JobListViewState>());
  List<JobListView> _jobListViews = [];

  @override
  void initState() {
    super.initState();
    _initControllers(); // 先初始化控制器
    _initializeDataAfterControllers(); // 然后执行需要等待关键词的操作
  }

  Future<void> _initializeDataAfterControllers() async {
    await _fetchKeywords();
    _searchController.addListener(() {
      setState(() {});
    });
    _mainTabController.addListener(_onMainTabChanged);
    _subTabController.addListener(_onSubTabChanged);
    _initializeListViews(_mainTabController.index, _subTabController.index);
  }

  void _initControllers() {
    _mainTabController = TabController(length: _keywords.length, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
  }

  void _initializeListViews(int mainTabIndex, int subTabIndex) {
    if (_keywords.isEmpty || mainTabIndex >= _keywords.length) return;
    final selectedType = _keywords[mainTabIndex];
    final selectedTag = _getSubTabTag(subTabIndex);

    // 检查是否需要重新创建JobListView实例
    bool needsRecreate = _jobListViews.isEmpty;
    
    if (!needsRecreate) {
      // 如果已经存在JobListView实例，直接触发重新加载
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listViewKeys[subTabIndex].currentState != null) {
          _listViewKeys[subTabIndex].currentState!._loadJobs(
            isNewTab: true,
            type: selectedType,
            tag: selectedTag
          );
        }
      });
      return;
    }
    
    // 首次创建JobListView实例
    _jobListViews = List.generate(
      3,
      (index) => JobListView(
        key: _listViewKeys[index],
        onLoadMore: (String? type, String? tag) => widget.onLoadMore(type, tag),
        onRefresh: (String? type, String? tag) => widget.onRefresh(type, tag),
        initialType: selectedType,
        initialTag: selectedTag,
      ),
    );

    // 只在当前选中的子标签页触发加载，避免多次加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listViewKeys[subTabIndex].currentState != null) {
        _listViewKeys[subTabIndex].currentState!._loadJobs(
          isNewTab: true,
          type: selectedType,
          tag: selectedTag
        );
      }
    });
  }

  String _getSubTabTag(int index) {
    switch (index) {
      case 0:
        return "recommended"; // Example tag for "推荐"
      case 1:
        return "nearby"; // Example tag for "附近"
      case 2:
        return "latest"; // Example tag for "最新"
      default:
        return "";
    }
  }

  void _onMainTabChanged() {
    if (_mainTabController.indexIsChanging ||
        !_mainTabController.indexIsChanging) {
      _subTabController.index = 0; // Reset sub tab on main tab change
      // 不在这里调用_initializeListViews，避免重复初始化
      // 让onTap事件处理初始化
      setState(() {});
    }
  }

  void _onSubTabChanged() {
    // 当子标签变化时，确保当前选中的子标签页重新加载数据
    if (!_subTabController.indexIsChanging) {
      int currentIndex = _subTabController.index;
      final selectedType = _keywords[_mainTabController.index];
      final selectedTag = _getSubTabTag(currentIndex);
      
      // 触发当前选中子标签的数据重新加载
      if (_listViewKeys[currentIndex].currentState != null) {
        _listViewKeys[currentIndex].currentState!._loadJobs(
          isNewTab: true,
          type: selectedType,
          tag: selectedTag
        );
      }
    }
    setState(() {});
  }

  Future<void> _fetchKeywords() async {
    setState(() {});
    try {
      final response = await dio.get("/job/tags");
      if (response.statusCode == 200 &&
          response.data['code'] == 200 &&
          response.data['data'] is List) {
        setState(() {
          _keywords = response.data['data'].cast<String>();
        });
        _disposeControllers();
        _initControllers();
      }
    } on DioException {
      setState(() {
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
        _disposeControllers();
        _initControllers();
      });
    } finally {
      if (_keywords.isNotEmpty) {}
    }
  }

  void _disposeControllers() {
    _mainTabController.dispose();
    _subTabController.dispose();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _disposeControllers();
    super.dispose();
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
  Widget build(BuildContext context) {
    if (_keywords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
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
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
            ),
            onSubmitted: _onSearch,
          ),
        ),
        Container(
          // BoxDecoration 用于装饰 Container
          decoration: BoxDecoration(
            color: Colors.white, // 设置 Container 的背景颜色为白色
            boxShadow: [
              // boxShadow 属性定义阴影效果，这里是一个包含单个 BoxShadow 的列表
              BoxShadow(
                color: Colors.green, // 阴影颜色为绿色
                spreadRadius: 2, // 阴影扩散半径，正值 outward，负值 inward，这里扩散 1 像素
                blurRadius: 4, // 阴影模糊半径，值越大阴影越模糊，这里模糊半径为 4 像素
              ),
            ],
          ),
          child: TabBar(
            // Container 的子 Widget 是 TabBar，实现了 Tab 标签页效果
            controller: _mainTabController,
            // TabBar 的控制器，用于管理 Tab 页的切换
            indicatorColor: const Color(0xFF4CAF50),
            // 指示器颜色，即 Tab 选中时的下划线颜色，这里是绿色 (0xFF4CAF50)
            labelColor: const Color(0xFF4CAF50),
            // 选中 Tab 标签文本颜色，这里是绿色 (0xFF4CAF50)
            unselectedLabelColor: Colors.grey,
            // 未选中 Tab 标签文本颜 色，这里是灰色
            isScrollable: true,
            // 设置 TabBar 是否可滚动，如果 Tab 标签过多超出屏幕宽度，设置为 true 可以水平滚动
            tabAlignment: TabAlignment.start,
            // 设置 Tab 标签对齐方式，这里是从左侧开始对齐
            tabs: _keywords
                .map((keyword) => Tab(
                      text: keyword,
                      iconMargin: EdgeInsets.zero,
                    ))
                .toList(),
            // 修改onTap事件，确保只在这里调用_initializeListViews
            onTap: (index) {
              _subTabController.index = 0;
              // 在这里调用_initializeListViews，而不是在_onMainTabChanged中
              _initializeListViews(index, 0);
              setState(() {});
            },
          ),
        ),
        // 副Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _subTabController,
            indicatorColor: const Color(0xFF4CAF50),
            labelColor: const Color(0xFF4CAF50),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "推荐"),
              Tab(text: "附近"),
              Tab(text: "最新"),
            ],
            // 修改onTap事件，确保只在这里调用_initializeListViews
            onTap: (index) {
              // 在这里调用_initializeListViews，而不是在_onSubTabChanged中
              _initializeListViews(_mainTabController.index, index);
              setState(() {});
            },
        ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            physics: const NeverScrollableScrollPhysics(),
            // Prevent swiping between sub-tabs
            children: _jobListViews,
          ),
        ),
      ],
    );
  }
}

class JobListView extends StatefulWidget {
  final Future<List<Job>> Function(String? type, String? tag) onLoadMore;
  final Future<List<Job>> Function(String? type, String? tag) onRefresh;
  final String initialType;
  final String initialTag;

  const JobListView({
    super.key,
    required this.onLoadMore,
    required this.onRefresh,
    required this.initialType,
    required this.initialTag,
  });

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView> {
  final ScrollController _scrollController = ScrollController();
  final List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialLoad = true; // Flag to track initial load

  @override
  void initState() {
    super.initState();
    // 移除这里的初始加载，避免与addPostFrameCallback中的加载重复
    // 初始加载将完全由父组件通过GlobalKey控制
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadJobs(
      {bool isRefresh = false,
      String? type,
      String? tag,
      bool isNewTab = false}) async {
    print("JobListView._loadJobs 被调用");
    print("isRefresh: $isRefresh, type: $type, tag: $tag, isNewTab: $isNewTab");
    if (_isLoading && !isRefresh && !isNewTab) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (isRefresh) {
        final newJobs = await widget.onRefresh(
            type ?? widget.initialType, tag ?? widget.initialTag);
        setState(() {
          _jobs.clear();
          _jobs.addAll(newJobs);
        });
      } else {
        final newJobs = await widget.onLoadMore(
            type ?? widget.initialType, tag ?? widget.initialTag);
        setState(() {
          if (isNewTab) {
            _jobs.clear();
          }
          _jobs.addAll(newJobs);
          _isLoading = false;
        });
      }
      setState(() {
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
    _loadJobs(
        isRefresh: true, type: widget.initialType, tag: widget.initialTag);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadJobs(type: widget.initialType, tag: widget.initialTag);
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
              onPressed: () =>
                  _loadJobs(type: widget.initialType, tag: widget.initialTag),
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
        await _loadJobs(
            isRefresh: true, type: widget.initialType, tag: widget.initialTag);
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
