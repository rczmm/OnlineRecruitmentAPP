import 'package:flutter/material.dart';
import 'package:zhaopingapp/ChatScreen.dart';
import 'package:zhaopingapp/features/chat/presentation/screens/chat_screen.dart';
import 'package:zhaopingapp/models/chat.dart';
import 'package:zhaopingapp/services/chat_service.dart';
import '../widgets/chat_item.dart';
import '../widgets/list_section_header.dart';

class ChatTabView extends StatefulWidget {
  final ChatService chatService;

  const ChatTabView({super.key, required this.chatService});

  @override
  State<ChatTabView> createState() => _ChatTabViewState();
}

class _ChatTabViewState extends State<ChatTabView> {
  List<Chat> _chatList = [];
  List<Chat> _filteredChatList = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChatList();
    _searchController.addListener(_filterChatList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChatList);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChatList() async {
    // Simplified loading state management
    if (!mounted) return;
    setState(() {
      _isLoading = _chatList.isEmpty; // Show full loading only if list is empty
      _errorMessage = null;
    });

    try {
      final chatList = await widget.chatService.getChatList();
      chatList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      if (!mounted) return;
      setState(() {
        _chatList = chatList;
        _filterChatList(); // Apply filter immediately
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '获取聊天列表失败'; // Keep message simple for UI
        _isLoading = false;
        _chatList = [];
        _filteredChatList = [];
      });
      debugPrint("Error fetching chat list: $e"); // Log detailed error
    }
  }

  void _filterChatList() {
    final query = _searchController.text.toLowerCase();
    // No need for setState here if called from listener,
    // but wrap in setState if called directly elsewhere
    setState(() {
      if (query.isEmpty) {
        _filteredChatList = List.from(_chatList);
      } else {
        _filteredChatList = _chatList.where((chat) {
          return chat.name.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // --- Date Header Logic (Keep as before) ---
  bool _shouldShowDateHeader(DateTime current, DateTime previous) {
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  String _getDateHeader(DateTime dateTime) {
    // ... (keep existing _getDateHeader logic)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) return '今天';
    if (messageDate == yesterday) return '昨天';
    if (today.difference(messageDate).inDays < 7) return '本周';
    return '更早';
  }

  // --- End Date Header Logic ---

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchChatList,
            child: _buildContent(), // Use a helper for content switching
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      // Adjusted padding
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索聊天',
          prefixIcon: const Icon(Icons.search, size: 22),
          // Slightly larger icon
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _searchController.clear, // Listener handles filter
                  splashRadius: 20, // Smaller splash
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Less rounded
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).dividerColor.withAlpha(30),
          // Use theme color
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          // Adjust padding
          isDense: true, // Make it more compact
        ),
        style: Theme.of(context).textTheme.bodyLarge, // Match text style
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }
    if (_chatList.isEmpty) {
      return _buildEmptyListWidget('暂无聊天记录');
    }
    if (_filteredChatList.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptyListWidget('未找到相关聊天');
    }
    return _buildChatListView();
  }

  Widget _buildChatListView() {
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
              ListSectionHeader(title: _getDateHeader(chat.lastMessageTime)),
            // Use InkWell for ripple effect
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      peerName: chat.name,
                      peerId: chat.id, // Ensure chat.id is the correct peer ID
                    ),
                  ),
                );
              },
              child: ChatItem(
                name: chat.name,
                message: chat.lastMessage,
                time: chat.lastMessageTime,
                avatarUrl: chat.avatarUrl,
              ),
            ),
            // Divider is handled by ListView.separated or added conditionally
            // if (index < _filteredChatList.length - 1)
            //   const Divider(height: 1, indent: 72, endIndent: 16),
          ],
        );
      },
    );
    // Alternative: Use ListView.separated for dividers
    /*
    return ListView.separated(
      itemCount: _filteredChatList.length,
      itemBuilder: (context, index) {
         // ... build header and InkWell + ChatItem ...
      },
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16),
    );
    */
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fetchChatList, child: const Text('重试')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            if (message == '暂无聊天记录') // Only show refresh if truly empty
              ElevatedButton(
                  onPressed: _fetchChatList, child: const Text('刷新')),
          ],
        ),
      ),
    );
  }
}
