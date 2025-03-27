import 'package:dio/dio.dart'; // Import DioException and CancelToken
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../core/network/dio_client.dart'; // Assuming dio is configured here
import '../widgets/job_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Job> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  bool _initialSearchDone = false; // Track if the first search has happened
  String? _error; // Store error message
  CancelToken? _cancelToken; // For cancelling requests

  // Define page size
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Use WidgetsBinding to ensure context is available for potential errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _cancelPreviousRequest(); // Cancel ongoing request on dispose
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger loading slightly before reaching the end
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  void _cancelPreviousRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('New search initiated');
      debugPrint('Previous search request cancelled.');
    }
    _cancelToken = null;
  }

  Future<void> _fetchJobs(String query, int page) async {
    // Ensure query is not empty for subsequent loads if needed
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults.clear();
          _hasMore = false;
          _initialSearchDone =
              true; // Mark search as done (even if empty query)
          _error = null;
        });
      }
      return;
    }

    _cancelPreviousRequest(); // Cancel previous before starting new
    _cancelToken = CancelToken();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null; // Clear previous error
        if (page == 1) {
          // Reset list only when starting a new search (page 1)
          _searchResults.clear();
          _currentQuery = query; // Update current query only on new search
          _currentPage = 1; // Reset page number
          _hasMore = true; // Assume there's more data initially
        }
      });
    }

    try {
      final response = await dio.post(
        '/job/list',
        data: {
          'keyword': query,
          'pageNum': page,
          'pageSize': _pageSize,
          // Send pageSize if API supports it
          // Add other potential default filters if needed, e.g., 'type': '', 'tag': ''
        },
        cancelToken: _cancelToken,
      );
      _cancelToken = null; // Clear token after success

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> jobsData = response.data['data']?['records'] ?? [];
        final List<Job> newJobs =
            jobsData.map((job) => Job.fromJson(job)).toList();

        setState(() {
          _searchResults.addAll(newJobs);
          _currentPage = page; // Update current page
          // Check if the number of results fetched is less than page size
          _hasMore = newJobs.length >= _pageSize;
          _isLoading = false;
          _initialSearchDone = true; // Mark that a search has been attempted
        });
      } else {
        // Handle API error response
        final errorMsg =
            response.data?['message'] ?? 'Failed to load search results';
        throw Exception('API Error: $errorMsg');
      }
    } on DioException catch (e) {
      _cancelToken = null; // Clear token on error
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Search request cancelled.');
        // Don't change state if cancelled, let the new request handle it
        return;
      }
      if (!mounted) return;
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = '网络连接超时';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器错误 (${e.response?.statusCode})';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接错误';
          break;
        default:
          errorMessage = '搜索失败，请重试';
      }
      setState(() {
        _isLoading = false;
        _error = errorMessage;
        _initialSearchDone = true; // Mark attempt as done even on error
        if (page == 1) {
          _searchResults.clear(); // Clear results on initial search error
        }
      });
    } catch (e) {
      _cancelToken = null; // Clear token on error
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '发生意外错误: $e';
        _initialSearchDone = true;
        if (page == 1) _searchResults.clear();
      });
    }
  }

  // Initiates a new search (starts from page 1)
  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    // Optional: Prevent searching for the same query again if results are already shown
    // if (trimmedQuery == _currentQuery && _searchResults.isNotEmpty) return;
    await _fetchJobs(trimmedQuery, 1);
    // Scroll to top after performing a new search
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // Loads the next page of results for the current query
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || _currentQuery.isEmpty) return;
    await _fetchJobs(_currentQuery, _currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus:
              widget.initialQuery == null || widget.initialQuery!.isEmpty,
          // Autofocus if no initial query
          decoration: const InputDecoration(
            hintText: '搜索职位、公司、技能...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textInputAction: TextInputAction.search,
          // Show search button on keyboard
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: Column(
        children: [
          // TODO: Implement functional filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterOption('薪资'),
                _buildFilterOption('经验'),
                _buildFilterOption('区域'), // Example filter
                _buildFilterOption('更多'), // Example filter
              ],
            ),
          ),
          // Search Results List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _searchResults.isEmpty) {
      // Show loading indicator only when loading initial results
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _searchResults.isEmpty) {
      // Show error message if initial search failed
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text('加载失败: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _performSearch(_currentQuery),
                child: const Text('重试'),
              )
            ],
          ),
        ),
      );
    }

    if (!_initialSearchDone && _searchResults.isEmpty) {
      // Before the first search is done, show nothing or a prompt
      return const Center(child: Text('输入关键词开始搜索职位'));
    }

    if (_searchResults.isEmpty) {
      // After search, if results are empty
      return const Center(child: Text('未找到相关职位'));
    }

    // Display the list of results
    return ListView.builder(
      controller: _scrollController,
      // Add 1 for the potential loading indicator at the end
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        // If it's the last item
        if (index == _searchResults.length) {
          // Show loading indicator if loading more, or 'no more' text, or nothing
          if (_isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            );
          } else if (!_hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('没有更多结果了', style: TextStyle(color: Colors.grey)),
              ),
            );
          } else {
            // If not loading but has more, show nothing
            return const SizedBox.shrink();
          }
        }
        // Otherwise, display the job card
        return JobCard(job: _searchResults[index]);
      },
    );
  }

  // Placeholder for filter options
  Widget _buildFilterOption(String title) {
    return InkWell(
      // Use InkWell for better tap feedback control
      onTap: () {
        // TODO: Implement filter selection logic (e.g., show bottom sheet or dialog)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('筛选功能 "$title" 待实现')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade700)),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}
