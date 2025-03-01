import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/job.dart';
import '../services/dio_client.dart';
import '../widgets/job_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Job> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentQuery = query;
      _currentPage = 1;
      _searchResults.clear();
    });

    try {
      final response = await dio.get('/jobs/search', queryParameters: {
        'keyword': query,
        'page': _currentPage,
      });

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> jobs = response.data['data']['jobs'];
        setState(() {
          _searchResults = jobs.map((job) => Job.fromJson(job)).toList();
          _hasMore = jobs.length >= 10; // 假设每页10条数据
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败：$e')),
      );
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.get('/jobs/search', queryParameters: {
        'keyword': _currentQuery,
        'page': _currentPage + 1,
      });

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> newJobs = response.data['data']['jobs'];
        setState(() {
          _searchResults.addAll(newJobs.map((job) => Job.fromJson(job)).toList());
          _currentPage++;
          _hasMore = newJobs.length >= 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载更多失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索职位、公司',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选选项栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterOption('薪资'),
                _buildFilterOption('经验'),
                _buildFilterOption('公司规模'),
                _buildFilterOption('更多筛选'),
              ],
            ),
          ),
          // 搜索结果列表
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('暂无搜索结果'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _searchResults.length) {
                        return JobCard(job: _searchResults[index]);
                      } else {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return TextButton(
      onPressed: () {
        // TODO: 实现筛选功能
      },
      child: Row(
        children: [
          Text(title),
          Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }
}