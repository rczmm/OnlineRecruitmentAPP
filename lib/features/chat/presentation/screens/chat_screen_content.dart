import 'package:flutter/material.dart';
import 'package:zhaopingapp/core/services/AuthService.dart';
import 'package:zhaopingapp/features/interaction/presentation/widgets/interaction_tab_view.dart';
import 'package:zhaopingapp/greeting_page.dart';
import 'package:zhaopingapp/services/chat_service.dart';
import 'package:zhaopingapp/features/chat/presentation/views/chat_tab_view.dart';
import 'package:zhaopingapp/common_phrases_page.dart';

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({super.key});

  @override
  State<ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext modalContext) {
        return _buildBottomSheetContent(modalContext); // Call helper
      },
    );
  }

  Widget _buildBottomSheetContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('消息设置',
              style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
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
              final String? userId = await _authService.getCurrentUserId();
              Navigator.pop(context);
              if (userId != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CommonPhrasesPage(userId: userId)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('无法获取用户信息，请稍后重试')),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          // Removed extra SizedBox(height: 8) as bottom padding is handled by Padding widget
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
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
                splashRadius: 24,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ChatTabView(chatService: _chatService),
              const InteractionTabView(),
            ],
          ),
        ),
      ],
    );
  }
}
