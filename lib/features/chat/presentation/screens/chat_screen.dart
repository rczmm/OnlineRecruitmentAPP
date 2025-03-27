import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'
    show
        BarAreaData,
        FlDotData,
        FlGridData,
        FlTitlesData,
        FlBorderData,
        FlSpot,
        LineChart,
        LineChartBarData,
        LineChartData;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/ChatScreen.dart';
import 'package:zhaopingapp/common_phrases_page.dart';
import 'package:zhaopingapp/greeting_page.dart';
import 'package:zhaopingapp/models/chat.dart';
import 'package:zhaopingapp/services/chat_service.dart';
import 'package:zhaopingapp/widgets/JobCardWidget.dart';

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({super.key});

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _interactionTabController;

  // Use your actual ChatService
  final ChatService _chatService = ChatService();
  List<Chat> _chatList = [];
  List<Chat> _filteredChatList = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _interactionTabController = TabController(length: 2, vsync: this);
    _fetchChatList();
    _searchController.addListener(_filterChatList);
  }

  Future<void> _fetchChatList() async {
    // Show loading indicator only on initial load
    if (_chatList.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      // For refresh, clear previous error but don't show full loading spinner
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      // Fetch using your service
      final chatList = await _chatService.getChatList();
      // Sort by time (descending)
      chatList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      setState(() {
        _chatList = chatList;
        _filterChatList(); // Apply search filter
        _isLoading = false;
        // _errorMessage = null; // Already cleared above or at start
      });
    } catch (e) {
      // Catch exceptions thrown by the service
      setState(() {
        // Display a user-friendly message, potentially based on exception type
        _errorMessage = '获取聊天列表失败: $e';
        _isLoading = false; // Stop loading indicator on error
        _chatList = []; // Clear potentially stale data on error
        _filteredChatList = [];
      });
      // Optional: Log the full error for debugging
      debugPrint("Error caught in _fetchChatList: $e");
    }
  }

  void _filterChatList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Wrap filtering in setState to ensure UI updates
      if (query.isEmpty) {
        _filteredChatList = List.from(_chatList);
      } else {
        _filteredChatList = _chatList.where((chat) {
          return chat.name.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query);
        }).toList();
      }
    });
    // No need for extra setState((){}) if filtering logic is inside setState
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interactionTabController.dispose();
    _searchController.removeListener(_filterChatList);
    _searchController.dispose();
    super.dispose();
  }

  bool _shouldShowDateHeader(DateTime current, DateTime previous) {
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  String _getDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) return '今天';
    if (messageDate == yesterday) return '昨天';
    if (today.difference(messageDate).inDays < 7) return '一周内';
    // Consider using intl package for better date formatting:
    // return DateFormat('yyyy-MM-dd').format(messageDate);
    return '更早';
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('消息设置',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.textsms_outlined),
                  title: const Text("招呼语设置"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GreetingPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_quote_outlined),
                  title: const Text("常用语设置"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final String? userId =
                        await FlutterSecureStorage().read(key: 'userId');
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CommonPhrasesPage(
                                  userId: userId,
                                )));
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main widget structure remains the same
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '聊天'),
                  Tab(text: '互动'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: '消息设置',
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChatTabContent(),
              _buildInteractionTabContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatTabContent() {
    // Structure remains the same
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索聊天记录',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => _searchController
                          .clear(), // Listener will trigger filter
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchChatList,
            child: _buildChatList(), // Delegate list building
          ),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    // Logic remains the same, but uses the updated ChatItem
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        /* Error display */
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _fetchChatList, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    if (_chatList.isEmpty) {
      return Center(
        /* Empty state for no chats ever */
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无聊天记录', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchChatList, child: const Text('刷新')),
          ],
        ),
      );
    }

    if (_filteredChatList.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('未找到与 "${_searchController.text}" 相关的聊天',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredChatList.length,
      itemBuilder: (context, index) {
        final chat = _filteredChatList[index];
        final bool showHeader = index == 0 ||
            _shouldShowDateHeader(chat.lastMessageTime,
                _filteredChatList[index - 1].lastMessageTime);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              ListSection(title: _getDateHeader(chat.lastMessageTime)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      peerName: chat.name,
                      peerId: chat.id,
                    ),
                  ),
                );
              },
              child: ChatItem(
                name: chat.name,
                message: chat.lastMessage,
                time: chat.lastMessageTime,
                avatarUrl: chat.avatarUrl, // Pass avatarUrl
              ),
            ),
            if (index < _filteredChatList.length - 1)
              const Divider(height: 1, indent: 72, endIndent: 16),
          ],
        );
      },
    );
  }

  Widget _buildInteractionTabContent() {
    final List<FlSpot> viewData1 = const [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 5),
      FlSpot(5, 3),
      FlSpot(6, 4),
    ];
    final List<FlSpot> viewData2 = const [
      FlSpot(0, 2),
      FlSpot(1, 3),
      FlSpot(2, 2),
      FlSpot(3, 4),
      FlSpot(4, 3),
      FlSpot(5, 5),
      FlSpot(6, 4),
    ];
    final List<String> tags = [
      '全部',
      '附近',
      'Java',
      '不限经验',
      'Python',
      '产品经理',
      '应届生'
    ];
    final List<Map<String, String>> viewedJobs = [
      {'title': '高级 Flutter 开发工程师', 'company': '科技公司 A'},
      {'title': 'UI/UX 设计师', 'company': '设计工作室 B'},
      {'title': '后端 Java 工程师', 'company': '互联网大厂 C'},
    ];
    final List<Map<String, String>> interestedJobs = [
      {'title': '数据分析师', 'company': '金融科技 D'},
      {'title': '产品经理 (AI 方向)', 'company': '创业公司 E'},
      {'title': '前端工程师 (React)', 'company': '电商平台 F'},
      {'title': '游戏策划', 'company': '游戏公司 G'},
    ];

    return Column(
      children: [
        TabBar(
          controller: _interactionTabController,
          tabs: const [
            Tab(text: '看过我的'),
            Tab(text: '推荐职位'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _interactionTabController,
            children: [
              // --- "Viewed Me" Content ---
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("近期访问趋势",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    AspectRatio(
                      aspectRatio: 1.8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 10.0),
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              _buildLineChartBarData(viewData1, Colors.blue),
                              _buildLineChartBarData(viewData2, Colors.green),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("谁看过我",
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewedJobs.length,
                      itemBuilder: (context, index) {
                        final job = viewedJobs[index];
                        return JobCardWidget(
                          title: job['title']!,
                          company: job['company']!,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // --- "Recommended Jobs" Content ---
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: tags
                          .map((tag) => ChoiceChip(
                                label: Text(tag),
                                selected: tag == '全部',
                                onSelected: (selected) {
                                  debugPrint('Selected tag: $tag');
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: interestedJobs.length,
                      itemBuilder: (context, index) {
                        final job = interestedJobs[index];
                        return JobCardWidget(
                          title: job['title']!,
                          company: job['company']!,
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

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

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final DateTime time;
  final String? avatarUrl; // Use String? for optional avatar

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.avatarUrl, // Make it optional
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dt.year, dt.month, dt.day);

    if (messageDate == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (today.difference(messageDate).inDays == 1) {
      return '昨天';
    } else {
      // Consider using intl package for locale-aware formatting
      return '${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a placeholder if avatarUrl is null or empty
    final bool hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
        backgroundColor: Colors.grey[300], // Show background if no image
        child: !hasAvatar
            ? const Icon(Icons.person_outline,
                color: Colors.white, size: 20) // Smaller icon
            : null,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Text(
        // Only show time, no badge column needed now
        _formatTime(time),
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      // Optional: Add contentPadding for finer control
      // contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}

class ListSection extends StatelessWidget {
  final String title;

  const ListSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
