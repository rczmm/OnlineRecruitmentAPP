// lib/features/interaction/presentation/views/interaction_tab_view.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- Placeholder Model Imports (Replace with your actual paths) ---
import 'package:zhaopingapp/models/visit_trend_point.dart';
import 'package:zhaopingapp/models/viewer_info.dart';
import 'package:zhaopingapp/models/job.dart'; // Updated Job model import

// --- Placeholder Service Imports (Replace with your actual paths) ---
import 'package:zhaopingapp/services/interaction_service.dart';
import 'package:zhaopingapp/services/job_service.dart';

// --- Placeholder Widget Imports (Replace with your actual paths) ---
import 'package:zhaopingapp/widgets/job_card_widget.dart'; // Updated JobCardWidget import
import 'package:zhaopingapp/features/interaction/presentation/widgets/viewer_card_widget.dart'; // Viewer card import

class InteractionTabView extends StatefulWidget {
  const InteractionTabView({super.key});

  @override
  State<InteractionTabView> createState() => _InteractionTabViewState();
}

class _InteractionTabViewState extends State<InteractionTabView>
    with TickerProviderStateMixin {
  late TabController _interactionTabController;

  // --- State Variables ---
  // Services (Inject these properly in a real app using get_it, Provider, Riverpod, etc.)
  final InteractionService _interactionService = InteractionService();
  final JobService _jobService = JobService();

  // "Viewed Me" State
  bool _isTrendLoading = true;
  bool _isViewersLoading = true;
  String? _trendError;
  String? _viewersError;
  List<VisitTrendPoint> _trendPoints = [];
  List<ViewerInfo> _viewersList = [];

  // "Recommended Jobs" State - Updated Type
  bool _isTagsLoading = true;
  bool _isJobsLoading = true;
  String? _tagsError;
  String? _jobsError;
  List<String> _tagsList = ['全部']; // Start with '全部'
  // Use the Job model here
  List<Job> _recommendedJobsList = [];
  List<Job> _filteredJobsList = [];
  String _selectedTag = '全部';

  @override
  void initState() {
    super.initState();
    _interactionTabController = TabController(length: 2, vsync: this);
    // Fetch initial data
    _fetchVisitTrend();
    _fetchViewers();
    _fetchTags();
    _fetchRecommendedJobs(); // Fetch initial jobs (all)
  }

  @override
  void dispose() {
    _interactionTabController.dispose();
    super.dispose();
  }

  // --- Data Fetching Methods ---
  Future<void> _fetchVisitTrend() async {
    if (!mounted) return;
    setState(() {
      _isTrendLoading = true;
      _trendError = null;
    });
    try {
      final data = await _interactionService.getVisitTrend();
      if (!mounted) return;
      setState(() {
        _trendPoints = data;
        _isTrendLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _trendError = "无法加载访问趋势";
        _isTrendLoading = false;
      });
      debugPrint("Error fetching visit trend: $e");
    }
  }

  Future<void> _fetchViewers() async {
    if (!mounted) return;
    setState(() {
      _isViewersLoading = true;
      _viewersError = null;
    });
    try {
      final data = await _interactionService.getViewers();
      if (!mounted) return;
      setState(() {
        _viewersList = data;
        _isViewersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _viewersError = "无法加载访客列表";
        _isViewersLoading = false;
      });
      debugPrint("Error fetching viewers: $e");
    }
  }

  Future<void> _fetchTags() async {
    if (!mounted) return;
    setState(() {
      _isTagsLoading = true;
      _tagsError = null;
    });
    try {
      final data = await _jobService.getRecommendationTags();
      if (!mounted) return;
      // Ensure '全部' is present and first if needed, or handle API response
      final tags = data.contains('全部') ? data : ['全部', ...data];
      setState(() {
        _tagsList = tags;
        _isTagsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tagsError = "无法加载标签";
        _isTagsLoading = false;
      });
      debugPrint("Error fetching tags: $e");
    }
  }

  Future<void> _fetchRecommendedJobs({bool isRefresh = false}) async {
    if (!mounted) return;
    // Only show loading indicator on initial load or explicit refresh
    if (_recommendedJobsList.isEmpty || isRefresh) {
      setState(() {
        _isJobsLoading = true;
        _jobsError = null;
      });
    } else {
      setState(() {
        _jobsError = null;
      }); // Clear error on subsequent loads
    }

    try {
      // Fetch jobs based on the *currently selected* tag if API supports it
      // Otherwise, fetch all and filter client-side
      // Service method now returns Future<List<Job>>
      final data = await _jobService.getRecommendedJobs(
          tag: _selectedTag == '全部' ? null : _selectedTag);
      if (!mounted) return;
      setState(() {
        _recommendedJobsList = data; // Store List<Job>
        _filterRecommendedJobs(); // Apply filter
        _isJobsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _jobsError = "无法加载推荐职位";
        _isJobsLoading = false;
        _recommendedJobsList = []; // Clear List<Job>
        _filteredJobsList = [];
      });
      debugPrint("Error fetching recommended jobs: $e");
    }
  }

  void _filterRecommendedJobs() {
    // Filtering logic might need adjustment based on Job fields if doing client-side
    setState(() {
      if (_selectedTag == '全部') {
        _filteredJobsList = List.from(_recommendedJobsList);
      } else {
        // Example client-side filter (adjust logic as needed)
        _filteredJobsList = _recommendedJobsList
            .where((job) =>
                job.title.toLowerCase().contains(_selectedTag.toLowerCase()) ||
                job.tags.any(
                    (t) => t.toLowerCase() == _selectedTag.toLowerCase()) ||
                job.company.toLowerCase().contains(_selectedTag.toLowerCase()))
            .toList();
      }
    });
  }

  void _onTagSelected(String tag) {
    if (_selectedTag == tag) return; // No change
    setState(() {
      _selectedTag = tag;
    });
    // Refetch data based on the new tag
    _fetchRecommendedJobs();
    // OR if filtering client-side: _filterRecommendedJobs();
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _interactionTabController,
          tabs: const [
            Tab(text: '看过我的'),
            Tab(text: '推荐职位'),
          ],
          // Optional: Customize TabBar appearance
          // labelColor: Theme.of(context).colorScheme.primary,
          // unselectedLabelColor: Theme.of(context).hintColor,
          // indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          child: TabBarView(
            controller: _interactionTabController,
            children: [
              _buildViewedMeContent(context),
              _buildRecommendedJobsContent(context),
            ],
          ),
        ),
      ],
    );
  }

  // --- Build methods for sub-tabs ---
  Widget _buildViewedMeContent(BuildContext context) {
    return SingleChildScrollView(
      // Use ListView for better performance if content grows
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Trend Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child:
                Text("近期访问趋势", style: Theme.of(context).textTheme.titleMedium),
          ),
          _buildTrendChart(), // Extracted chart building
          const Divider(thickness: 6, height: 20),

          // --- Viewers Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              // Add refresh button
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("谁看过我", style: Theme.of(context).textTheme.titleMedium),
                if (!_isViewersLoading) // Show refresh only when not loading
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _fetchViewers,
                    tooltip: '刷新访客列表',
                    splashRadius: 20,
                  )
              ],
            ),
          ),
          _buildViewersList(), // Extracted list building
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecommendedJobsContent(BuildContext context) {
    return Column(
      children: [
        // --- Tags Section ---
        _buildTagsSelector(), // Extracted tags building

        const Divider(height: 1),

        // --- Jobs List Section ---
        Expanded(
          child: _buildJobsList(), // Extracted jobs list building
        ),
      ],
    );
  }

  // --- Helper Build Widgets ---

  Widget _buildLoadingIndicator() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    if (_isTrendLoading) {
      return SizedBox(height: 180, child: _buildLoadingIndicator());
    }
    if (_trendError != null) {
      return SizedBox(
          height: 180,
          child: _buildErrorWidget(_trendError!, _fetchVisitTrend));
    }
    if (_trendPoints.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('暂无访问数据')));
    }

    // Convert data to FlSpot
    final spots = _trendPoints.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final point = entry.value;
      return FlSpot(index, point.count.toDouble());
    }).toList();

    // Find max Y value for chart scaling
    double maxY = 0;
    if (spots.isNotEmpty) {
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    maxY = (maxY + 1).ceilToDouble(); // Add some padding

    final maxX = (_trendPoints.length - 1).toDouble();

    return AspectRatio(
      aspectRatio: 1.8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 24.0, 10.0),
        // Adjust padding
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              // Basic example, customize further
              show: true,
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // Hide bottom for now
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (maxY / 4).ceilToDouble(), // Dynamic interval
                      getTitlesWidget: (value, meta) {
                        // Don't show 0 label if minY is 0
                        if (value == 0 && meta.min == 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(value.toInt().toString(),
                            style: const TextStyle(fontSize: 10));
                      })),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: maxX < 0 ? 0 : maxX,
            // Handle case with no data
            minY: 0,
            // Start Y axis at 0
            maxY: maxY < 1 ? 1 : maxY,
            // Ensure maxY is at least 1
            lineBarsData: [
              _buildLineChartBarData(
                  spots, Theme.of(context).colorScheme.primary),
              // Add more lines if needed
            ],
            // Optional: Add touch interaction
            // lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(tooltipBgColor: Colors.blueGrey)),
          ),
        ),
      ),
    );
  }

  Widget _buildViewersList() {
    if (_isViewersLoading) return _buildLoadingIndicator();
    if (_viewersError != null) {
      return _buildErrorWidget(_viewersError!, _fetchViewers);
    }
    if (_viewersList.isEmpty) {
      return const Center(
          child:
              Padding(padding: EdgeInsets.all(32.0), child: Text('还没有人看过你哦')));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _viewersList.length,
      itemBuilder: (context, index) {
        return ViewerCardWidget(viewer: _viewersList[index]);
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 72, endIndent: 16), // Indent divider
    );
  }

  Widget _buildTagsSelector() {
    if (_isTagsLoading) {
      return const SizedBox(
          height: 50,
          child: Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))));
    }
    if (_tagsError != null) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_tagsError!, style: const TextStyle(color: Colors.red)));
    }
    // Don't show error retry for tags, maybe just log it

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _tagsList
            .map((tag) => ChoiceChip(
                  label: Text(tag),
                  selected: _selectedTag == tag,
                  onSelected: (selected) {
                    if (selected) _onTagSelected(tag);
                  },
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  // Use theme color
                  backgroundColor: Theme.of(context).dividerColor.withAlpha(30),
                  // Background for unselected
                  side: BorderSide.none, // Remove border
                ))
            .toList(),
      ),
    );
  }

  Widget _buildJobsList() {
    if (_isJobsLoading) return _buildLoadingIndicator();
    if (_jobsError != null) {
      return _buildErrorWidget(
          _jobsError!, () => _fetchRecommendedJobs(isRefresh: true));
    }
    if (_filteredJobsList.isEmpty) {
      if (_selectedTag == '全部') {
        return const Center(
            child:
                Padding(padding: EdgeInsets.all(32.0), child: Text('暂无推荐职位')));
      } else {
        return Center(
            child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('暂无符合 "$_selectedTag" 的推荐职位')));
      }
    }

    // Use RefreshIndicator if you want pull-to-refresh for jobs specifically
    return RefreshIndicator(
      onRefresh: () => _fetchRecommendedJobs(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
        // Add padding around the list
        itemCount: _filteredJobsList.length,
        itemBuilder: (context, index) {
          // Get the Job object
          final job = _filteredJobsList[index];
          // Pass the Job object to the updated JobCardWidget
          return JobCardWidget(job: job);
        },
      ),
    );
  }

  // --- Chart Helper ---
  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withAlpha(75), color.withAlpha(10)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
