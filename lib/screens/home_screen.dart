import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';
import 'search_screen.dart';

class JobList extends StatefulWidget {
  final List<Job> Function() onLoadMore;

  const JobList({super.key, required this.onLoadMore});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> with TickerProviderStateMixin {
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
  late TabController _mainTabController = TabController(length: _keywords.length, vsync: this);
  late TabController _subTabController = TabController(length: 3, vsync: this);
  List<JobList> _jobLists = [];
  final ScrollController _scrollController = ScrollController();
  List<Job> _jobs = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchKeywords();
    // 初始化三个 JobList，对应推荐、附近、最新三个标签页
    _jobLists = List.generate(3, (index) => JobList(
      key: GlobalKey<_JobListState>(),
      onLoadMore: _refreshJobList,
    ));
    _loadJobs();
    _scrollController.addListener(_onScroll);
  }
  
  void _loadJobs() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      _jobs.addAll(widget.onLoadMore());
      setState(() {
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadJobs();
    }
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // 刷新职位列表数据
  List<Job> _refreshJobList() {
    // TODO: 这里将来需要根据_currentMainTab和_currentSubTab调用后端接口获取数据
    return _generateSampleJobs();
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
    _scrollController.dispose();
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
                tabs: _keywords.map((keyword) => Tab(
                  text: keyword,
                  height: 44,
                )).toList(),
                onTap: (index) {
                  setState(() {
                    _currentMainTab = _keywords[index];
                  });
                  _subTabController.index = 0;
                  _currentSubTab = '推荐';
                  // 刷新当前标签页的职位列表
                  if (_subTabController.index >= 0 && _subTabController.index < _jobLists.length) {
                    final state = (_jobLists[_subTabController.index].key as GlobalKey<_JobListState>).currentState;
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
            children: _jobLists.map((jobList) => jobList).toList(),
          ),
        ),
      ],
    );
  }
  // 生成示例数据
  List<Job> _generateSampleJobs() {
    final titles = [
      '高级Java开发工程师',
      'Flutter移动开发工程师',
      'Python数据分析师',
      '前端开发工程师',
      'DevOps工程师',
      '产品经理',
      'UI设计师',
      '算法工程师',
      '测试工程师',
      '运维工程师'
    ];

    final companies = [
      {'name': '字节跳动', 'size': '10000人以上'},
      {'name': '腾讯科技', 'size': '10000人以上'},
      {'name': '阿里巴巴', 'size': '10000人以上'},
      {'name': '美团点评', 'size': '10000人以上'},
      {'name': '快手科技', 'size': '5000-10000人'},
      {'name': '小米科技', 'size': '5000-10000人'},
      {'name': '京东集团', 'size': '10000人以上'},
      {'name': '网易', 'size': '5000-10000人'},
      {'name': '百度', 'size': '10000人以上'},
      {'name': '滴滴出行', 'size': '5000-10000人'}
    ];

    final salaries = [
      '15k-25k',
      '20k-35k',
      '25k-45k',
      '30k-50k',
      '35k-60k',
      '40k-70k',
      '45k-80k',
      '50k-90k',
      '60k-100k',
      '面议'
    ];

    final locations = [
      '北京市朝阳区',
      '上海市浦东新区',
      '深圳市南山区',
      '广州市天河区',
      '杭州市西湖区',
      '成都市高新区',
      '武汉市洪山区',
      '南京市江宁区',
      '西安市雁塔区',
      '苏州市工业园区'
    ];

    final allTags = {
      '开发': ['Java', 'Spring Boot', 'MySQL', 'Redis', 'MQ', 'Flutter', 'Python', 'Django', 
              'React', 'Vue.js', 'Node.js', 'TypeScript', 'Docker', 'K8s', 'AWS'],
      '设计': ['UI设计', 'UE设计', 'Figma', 'Sketch', 'PhotoShop', '原型设计', '交互设计'],
      '产品': ['需求分析', '产品规划', '用户研究', '数据分析', 'Axure', '项目管理'],
      '算法': ['机器学习', '深度学习', 'NLP', '计算机视觉', 'PyTorch', 'TensorFlow']
    };

    final hrNames = ['王女士', '李先生', '张女士', '刘先生', '陈女士', '赵先生', '孙女士', '周先生', '吴女士', '郑先生'];

    return List.generate(10, (index) {
      final company = companies[index];
      final title = titles[index];
      String category = '';
      if (title.contains('开发')) category = '开发';
      else if (title.contains('设计')) category = '设计';
      else if (title.contains('产品')) category = '产品';
      else if (title.contains('算法')) category = '算法';
      else category = '开发';

      final tagPool = allTags[category] ?? allTags['开发']!;
      final selectedTags = (tagPool.toList()..shuffle()).take(3).toList();

      return Job(
        id: 'job_${index + 1}',
        title: title,
        salary: salaries[index],
        company: company['name']!,
        companySize: company['size']!,
        tags: selectedTags,
        hrName: hrNames[index],
        location: locations[index],
        workExperience: '3-5年',
        education: '本科及以上',
        benefits: ['五险一金', '年终奖', '带薪年假', '加班补助'],
        description: '负责公司核心业务系统的开发和维护工作',
        requirements: ['本科及以上学历', '3年以上相关工作经验', '良好的团队协作能力'],
        status: '未投递',
        date: DateTime.now().toString().substring(0, 10)
      );
    });
  }
}
