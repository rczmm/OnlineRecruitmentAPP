import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart'; // Assuming dio is configured here

import '../models/job.dart';
import '../widgets/job_card.dart';
import 'search_screen.dart';

// Define function types with pagination
typedef LoadJobsFunction = Future<List<Job>> Function(
    String? type, String? tag, int page);
typedef RefreshJobsFunction = Future<List<Job>> Function(
    String? type, String? tag); // Refresh usually gets the first page

class JobListContainer extends StatefulWidget {
  // Updated function signatures
  final LoadJobsFunction onLoadMore;
  final RefreshJobsFunction onRefresh; // Renamed for clarity, implies page 1

  const JobListContainer(
      {super.key, required this.onLoadMore, required this.onRefresh});

  @override
  State<JobListContainer> createState() => _JobListContainerState();
}

class _JobListContainerState extends State<JobListContainer>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<String> _keywords = [];
  TabController? _mainTabController; // Nullable initially
  TabController? _subTabController; // Nullable initially
  bool _isLoadingKeywords = true;
  String? _keywordError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetchKeywordsAndInitialize();
  }

  Future<void> _fetchKeywordsAndInitialize() async {
    setState(() {
      _isLoadingKeywords = true;
      _keywordError = null;
    });
    try {
      final response = await dio.get("/job/tags");
      if (response.statusCode == 200 &&
          response.data['code'] == 200 &&
          response.data['data'] is List) {
        if (!mounted) return;
        setState(() {
          _keywords = response.data['data'].cast<String>();
          if (_keywords.isEmpty) {
            _setFallbackKeywords(); // Use fallback if API returns empty list
          }
          _initControllers();
          _isLoadingKeywords = false;
        });
      } else {
        if (!mounted) return;
        _setFallbackKeywordsAndInit();
        setState(() {
          _keywordError = 'Failed to load categories: Invalid response';
          _isLoadingKeywords = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      _setFallbackKeywordsAndInit();
      setState(() {
        // Keep fallback keywords even on error
        _keywordError = 'Failed to load categories: ${e.message}';
        _isLoadingKeywords = false;
      });
    } catch (e) { // Catch other potential errors
      if (!mounted) return;
      _setFallbackKeywordsAndInit();
      setState(() {
        _keywordError = 'An unexpected error occurred: $e';
        _isLoadingKeywords = false;
      });
    }
  }

  void _setFallbackKeywords() {
    _keywords = [
      '技术开发', '产品运营', '设计创意', '市场营销',
      '人力资源', '金融财务', '教育培训', '医疗健康'
    ];
  }

  void _setFallbackKeywordsAndInit() {
    _setFallbackKeywords();
    _initControllers(); // Init controllers with fallback keywords
  }


  void _initControllers() {
    // Dispose previous controllers if they exist (e.g., on hot reload or error retry)
    _mainTabController?.dispose();
    _subTabController?.dispose();

    _mainTabController = TabController(length: _keywords.length, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);

    // Add listeners only once after initialization
    _mainTabController!.addListener(_onMainTabChanged);
    // No listener needed for subTabController if using onTap and setState
    // _subTabController!.addListener(_onSubTabChanged);
  }

  // Optional: Listener can handle programmatic changes or complex logic
  void _onMainTabChanged() {
    // Ensure the listener doesn't trigger during the build phase or disposal
    if (_mainTabController != null && _mainTabController!.indexIsChanging == false && mounted) {
      // If main tab changes, reset sub-tab and trigger rebuild
      if (_subTabController?.index != 0) {
        _subTabController?.index = 0;
      }
      // setState is crucial to rebuild the TabBarView with new props
      setState(() {});
    }
  }

  // void _onSubTabChanged() {
  //   if (_subTabController != null && _subTabController!.indexIsChanging == false && mounted) {
  //     setState(() {}); // Rebuild to pass new tag to JobListView
  //   }
  // }


  String _getSubTabTag(int index) {
    switch (index) {
      case 0: return "recommended";
      case 1: return "nearby";
      case 2: return "latest";
      default: return "";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mainTabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: query),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    // Ensure controllers are initialized before showing dialog
    if (_mainTabController == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulWidget for the dialog content if it needs its own state management
        // For simplicity, using current state here.
        int selectedIndex = _mainTabController!.index; // Capture current index

        return AlertDialog(
          title: const Text('选择职位类型', style: TextStyle(color: Color(0xFF4CAF50))),
          contentPadding: EdgeInsets.zero, // Remove default padding
          content: SizedBox(
            width: double.maxFinite,
            // Use StatefulBuilder if you need to update the dialog's internal state (e.g., selection highlight) without closing it
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              shrinkWrap: true,
              itemCount: _keywords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_keywords[index]),
                  onTap: () {
                    Navigator.pop(context);
                    if (_mainTabController!.index != index) {
                      _mainTabController!.animateTo(index);
                      // Reset sub-tab index directly
                      _subTabController?.index = 0;
                      // Let the listener or build method handle the update
                      // No need to call _initializeListViews
                      setState(() {}); // Trigger rebuild
                    }
                  },
                  textColor: selectedIndex == index ? const Color(0xFF4CAF50) : null,
                  trailing: selectedIndex == index ? const Icon(Icons.check, color: Color(0xFF4CAF50)) : null,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingKeywords) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle case where controllers might still be null after error
    if (_mainTabController == null || _subTabController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_keywordError ?? 'Failed to initialize tabs.'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchKeywordsAndInitialize,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    // Get current selected type safely
    final selectedType = (_keywords.isNotEmpty && _mainTabController!.index < _keywords.length)
        ? _keywords[_mainTabController!.index]
        : '';


    return Column(
      children: [
        // Search Bar
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
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => _searchController.clear(),
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Adjust padding
            ),
            onSubmitted: _onSearch,
          ),
        ),

        // Main Tabs with "More" button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TabBar(
                controller: _mainTabController!,
                indicatorColor: const Color(0xFF4CAF50),
                labelColor: const Color(0xFF4CAF50),
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _keywords.map((keyword) => Tab(text: keyword)).toList(),
                onTap: (index) {
                  // Reset sub-tab and trigger rebuild
                  _subTabController?.index = 0;
                  setState(() {});
                },
                padding: const EdgeInsets.only(right: 48), // Space for the button
              ),
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Match background
                    border: Border(left: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF4CAF50)), // Changed icon
                    onPressed: () => _showCategoryDialog(context),
                    tooltip: '展开所有分类',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Sub Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _subTabController!,
            indicatorColor: const Color(0xFF4CAF50),
            labelColor: const Color(0xFF4CAF50),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "推荐"),
              Tab(text: "附近"),
              Tab(text: "最新"),
            ],
            onTap: (index) {
              // Trigger rebuild
              setState(() {});
            },
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _subTabController!,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(3, (subIndex) {
              final selectedTag = _getSubTabTag(subIndex);
              // Generate JobListView directly, passing type/tag and using ValueKey
              return JobListView(
                key: ValueKey('$selectedType-$selectedTag'), // Unique key per tab combination
                onLoadMore: widget.onLoadMore,
                onRefresh: widget.onRefresh,
                initialType: selectedType,
                initialTag: selectedTag,
              );
            }),
          ),
        ),
      ],
    );
  }
}


// --- JobListView (with pagination support and didUpdateWidget) ---

class JobListView extends StatefulWidget {
  // Use updated function signatures
  final LoadJobsFunction onLoadMore;
  final RefreshJobsFunction onRefresh;
  final String initialType;
  final String initialTag;

  const JobListView({
    super.key, // Key is now passed by parent
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
  bool _isFirstLoad = true; // Track initial loading state
  bool _hasMore = true; // Assume there's more data initially
  int _currentPage = 1; // Start with page 1
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial load
    _loadJobs(isRefresh: true);
  }

  @override
  void didUpdateWidget(covariant JobListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If type or tag changes, treat it as a refresh (load page 1)
    if (oldWidget.initialType != widget.initialType ||
        oldWidget.initialTag != widget.initialTag) {
      _loadJobs(isRefresh: true);
    }
  }

  Future<void> _loadJobs({bool isRefresh = false}) async {
    // Prevent concurrent loading unless it's a refresh
    if (_isLoading) return;
    // Don't load more if we know there's no more data
    if (!isRefresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _error = null; // Clear previous errors on refresh
        _isFirstLoad = true; // Reset first load flag on refresh/tab change
      }
    });

    try {
      List<Job> newJobs;
      if (isRefresh) {
        _currentPage = 1; // Reset page number
        _hasMore = true; // Assume more data on refresh
        newJobs = await widget.onRefresh(widget.initialType, widget.initialTag);
      } else {
        // Load next page
        newJobs = await widget.onLoadMore(widget.initialType, widget.initialTag, _currentPage);
      }

      if (!mounted) return;

      setState(() {
        if (isRefresh) {
          _jobs.clear(); // Clear existing jobs on refresh
          // Scroll to top on refresh/tab change
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        }
        _jobs.addAll(newJobs);
        _currentPage++; // Increment page number for the *next* load
        _isLoading = false;
        _isFirstLoad = false; // Mark initial load as complete
        // Check if the backend indicated no more data (e.g., by returning an empty list)
        _hasMore = newJobs.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载数据失败: $e';
        _isLoading = false;
        _isFirstLoad = false; // Mark initial load attempt as complete even on error
      });
    }
  }

  void _onScroll() {
    // Load more when near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9 && // Trigger slightly before the end
        !_isLoading &&
        _hasMore) {
      _loadJobs(); // Load next page
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Clean up listener
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Display loading indicator only on the very first load for this tab
    if (_isFirstLoad && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Display error message if an error occurred
    if (_error != null && _jobs.isEmpty) { // Show error prominently if list is empty
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadJobs(isRefresh: true), // Retry calls refresh
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // Display empty state if no jobs and not loading/no error
    if (_jobs.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无相关职位信息', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadJobs(isRefresh: true),
              child: const Text('刷新试试'),
            ),
          ],
        ),
      );
    }

    // Build the list
    return RefreshIndicator(
      onRefresh: () => _loadJobs(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        // Add 1 to item count for the loading/no-more indicator at the bottom
        itemCount: _jobs.length + 1,
        itemBuilder: (context, index) {
          // Last item: show loading indicator or "no more data" message
          if (index == _jobs.length) {
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
                  child: Text('没有更多职位了', style: TextStyle(color: Colors.grey)),
                ),
              );
            } else {
              // If not loading and has more, show nothing (or a small spacer)
              return const SizedBox.shrink();
            }
          }
          // Regular job item
          return JobCard(job: _jobs[index]);
        },
      ),
    );
  }
}