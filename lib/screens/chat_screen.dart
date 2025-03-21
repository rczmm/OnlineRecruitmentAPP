import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart'
    show BarAreaData, FlSpot, LineChart, LineChartBarData, LineChartData;
import '../ChatScreen.dart';
import '../common_phrases_page.dart';
import '../greeting_page.dart';
import '../widgets/JobCardWidget.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({super.key});

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent>
    with TickerProviderStateMixin {
  // 混入 TickerProviderStateMixin 用于 TabController
  late TabController _tabController;
  late TabController _interactionTabController; // 互动Tab的控制器
  final ChatService _chatService = ChatService();
  List<Chat> _chatList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 初始化 TabController
    _interactionTabController = TabController(length: 2, vsync: this);
    _fetchChatList(); // 获取聊天列表
  }
  
  // 获取聊天列表
  Future<void> _fetchChatList() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final chatList = await _chatService.getChatList();
      
      setState(() {
        _chatList = chatList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '获取聊天列表失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // 释放 TabController
    _interactionTabController.dispose();
    super.dispose();
  }
  
  // 判断是否需要显示日期头部
  bool _shouldShowDateHeader(DateTime current, DateTime previous) {
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }
  
  // 获取日期头部文本
  String _getDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '今天';
    } else if (messageDate == yesterday) {
      return '昨天';
    } else if (today.difference(messageDate).inDays < 7) {
      return '一周内';
    } else {
      return '更早';
    }
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('消息设置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("招呼语设置"),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GreetingPage()),
                  );
                },
              ),
              ListTile(
                title: const Text("常用语设置"),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet first
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('常用语设置'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('您好！'),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('很高兴认识您'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: 处理常用语选择
                                },
                              ),
                              ListTile(
                                title: const Text('期待与您合作'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: 处理常用语选择
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('关闭'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CommonPhrasesPage(),
                                ),
                              );
                            },
                            child: const Text('更多设置'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 关闭 BottomSheet
                },
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          // 包含 TabBar 和设置图标的 Row
          children: [
            Expanded(
              // 使用 Expanded 使 TabBar 占据剩余空间
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '聊天'),
                  Tab(text: '我可能感兴趣的'),
                ],
              ),
            ),
            IconButton(
              // 设置图标
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsBottomSheet(context),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 聊天 Tab 内容
              Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '搜索',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchChatList,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(_errorMessage!,
                                        style: const TextStyle(color: Colors.red)),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _fetchChatList,
                                      child: const Text('重试'),
                                    ),
                                  ],
                                ),
                              )
                            : _chatList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.chat_bubble_outline,
                                            size: 64, color: Colors.grey),
                                        const SizedBox(height: 16),
                                        const Text('暂无聊天记录',
                                            style: TextStyle(color: Colors.grey)),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _fetchChatList,
                                          child: const Text('刷新'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _chatList.length,
                                    itemBuilder: (context, index) {
                                      final chat = _chatList[index];
                                      // 根据日期分组显示
                                      final bool showHeader = index == 0 ||
                                          _shouldShowDateHeader(
                                              chat.lastMessageTime,
                                              _chatList[index - 1].lastMessageTime);
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (showHeader)
                                            ListSection(
                                                title: _getDateHeader(chat.lastMessageTime)),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                    peerName: chat.name,
                                                    id: chat.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ChatItem(
                                              name: chat.name,
                                              message: chat.lastMessage,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                  ),
                ),
              ]),

              // 互动 Tab 内容
              Column(
                children: [
                  TabBar(
                    controller: _interactionTabController,
                    tabs: const [
                      Tab(text: '看过我的'),
                      Tab(text: '我可能感兴趣的'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _interactionTabController,
                      children: [
                        // 看过我的
                        Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 2,
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: LineChart(
                                    LineChartData(
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 3),
                                            FlSpot(1, 1),
                                            FlSpot(2, 4),
                                            FlSpot(3, 2),
                                            FlSpot(4, 5),
                                            FlSpot(5, 3),
                                            FlSpot(6, 4),
                                          ],
                                          isCurved: true,
                                          barWidth: 3,
                                          belowBarData:
                                              BarAreaData(show: false),
                                        ),
                                        LineChartBarData(
                                          spots: const [
                                            FlSpot(0, 2),
                                            FlSpot(1, 3),
                                            FlSpot(2, 2),
                                            FlSpot(3, 4),
                                            FlSpot(4, 3),
                                            FlSpot(5, 5),
                                            FlSpot(6, 4),
                                          ],
                                          isCurved: true,
                                          barWidth: 3,
                                          color: Colors.green,
                                          belowBarData:
                                              BarAreaData(show: false),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                            const Expanded(
                              // 使用 Expanded 使列表填充剩余空间
                              child: SingleChildScrollView(
                                // 添加 SingleChildScrollView
                                child: Column(
                                  children: [
                                    JobCardWidget(title: '职位A', company: '公司A'),
                                    JobCardWidget(title: '职位B', company: '公司B'),
                                    // ... 更多职位卡片
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                Chip(label: Text('全部')),
                                Chip(label: Text('附近')),
                                Chip(label: Text('Java')),
                                Chip(label: Text('不限经验')),
                                // ... 更多 Tag
                              ],
                            ),
                            const Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    JobCardWidget(title: '职位A', company: '公司A'),
                                    JobCardWidget(title: '职位B', company: '公司B'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;

  const ChatItem({super.key, required this.name, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
          child: Icon(Icons.person, color: Colors.green)), // 头像
      title: Text(name),
      subtitle: Text(message),
    );
  }
}

class ListSection extends StatelessWidget {
  final String title;

  const ListSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
