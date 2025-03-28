import 'package:flutter/material.dart';
import 'package:zhaopingapp/ChatScreen.dart';
import 'package:zhaopingapp/core/services/AuthService.dart';
import 'package:zhaopingapp/features/jobs/data/models/job_model.dart';
import 'package:zhaopingapp/services/job_service.dart';
import 'package:zhaopingapp/services/chat_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late bool _isFavorite;
  bool _isTogglingFavorite = false;
  bool _isInitiatingChat = false;

  final JobService _jobService = JobService();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.job.isFavorite;
  }

  Future<void> _handleInitiateChat() async {
    if (_isInitiatingChat) return;

    setState(() {
      _isInitiatingChat = true;
    });

    final String? senderId = await _authService.getCurrentUserId();
    if (senderId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('无法获取您的用户信息，请重新登录'), backgroundColor: Colors.red),
      );
      setState(() {
        _isInitiatingChat = false;
      });
      return;
    }

    final String receiverId = widget.job.hrUserId;
    if (receiverId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取招聘者信息'), backgroundColor: Colors.red),
      );
      setState(() {
        _isInitiatingChat = false;
      });
      return;
    }

    final success = await _chatService.initiateChat(
      senderId: senderId,
      receiverId: receiverId,
      jobId: widget.job.id,
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            peerName: widget.job.hrName,
            peerId: receiverId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('发起沟通失败，请稍后重试'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isInitiatingChat = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return; // Prevent multiple taps

    setState(() {
      _isTogglingFavorite = true;
    });

    final success =
        await _jobService.toggleFavorite(widget.job.id, _isFavorite);

    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    if (success) {
      setState(() {
        _isFavorite = !_isFavorite; // Toggle local state on success
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? '已收藏' : '已取消收藏'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message if toggle failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('操作失败，请稍后重试'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isTogglingFavorite = false;
    });
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // TODO: Implement actual sharing logic for each platform
        return AlertDialog(
          title: const Text('分享职位'),
          content: const Text('将职位分享到：'), // Add content text
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                debugPrint('Share via WeChat'); // Placeholder
              },
              child: const Text('微信'), // Use Chinese for consistency
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                debugPrint('Share via QQ'); // Placeholder
              },
              child: const Text('QQ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                debugPrint('Copy Link'); // Placeholder
                // Implement copy link logic using clipboard package
              },
              child: const Text('复制链接'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              // Style cancel button
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get theme data for consistent styling
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom; // Safe area padding

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title, style: theme.appBarTheme.titleTextStyle),
        // Use theme colors/styles
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined), // Use outlined icon
            tooltip: '分享',
            onPressed: _showShareDialog,
          ),
          // Favorite button with loading indicator
          _isTogglingFavorite
              ? const Padding(
                  padding: EdgeInsets.all(16.0), // Match IconButton padding
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)),
                )
              : IconButton(
                  icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: _isFavorite
                      ? Colors.redAccent
                      : theme.appBarTheme.iconTheme
                          ?.color, // Highlight if favorite
                  tooltip: _isFavorite ? '取消收藏' : '收藏',
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: Stack(
        children: [
          // Use Padding for bottom space instead of SizedBox
          SingleChildScrollView(
            // Add padding to account for the bottom button and safe area
            padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 80.0 + bottomPadding + 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textTheme, colorScheme),
                const SizedBox(height: 16),
                _buildCompanyInfo(theme, textTheme),
                const SizedBox(height: 16),
                _buildTags(theme),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.school_outlined,
                    '学历要求：${widget.job.education}', theme),
                _buildDetailRow(Icons.work_outline,
                    '工作经验：${widget.job.workExperience}', theme),
                const SizedBox(height: 24),
                _buildSectionTitle('岗位描述', textTheme),
                _buildDescription(textTheme),
                const SizedBox(height: 24),
                _buildSectionTitle('职位要求', textTheme),
                _buildBulletedList(
                    widget.job.requirements, textTheme, '暂无岗位要求'),
                const SizedBox(height: 24),
                _buildSectionTitle('岗位福利', textTheme),
                _buildBulletedList(widget.job.benefits, textTheme, '暂无岗位福利'),
                const SizedBox(height: 24),
                _buildSectionTitle('工作地点', textTheme),
                _buildLocation(theme),
                const SizedBox(height: 24),
                _buildSectionTitle('招聘者信息', textTheme),
                _buildHrInfo(theme, textTheme),
              ],
            ),
          ),
          _buildBottomCommunicateButton(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Align top
      children: [
        Expanded(
          // Allow title to wrap if needed
          child: Text(
            widget.job.title,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          widget.job.salary,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary, // Use theme primary color
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfo(ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(15),
        // Use theme color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Use company logo if available, otherwise placeholder
          CircleAvatar(
            radius: 25,
            backgroundColor:
                theme.colorScheme.primaryContainer.withOpacity(0.2),
            backgroundImage: widget.job.companyLogo.isNotEmpty
                ? NetworkImage(widget.job.companyLogo)
                : null,
            child: widget.job.companyLogo.isEmpty
                ? Icon(Icons.business_outlined,
                    size: 30, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            // Allow text to take available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.job.company,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.job.companySize,
                  style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ThemeData theme) {
    if (widget.job.tags.isEmpty)
      return const SizedBox.shrink(); // Hide if no tags
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          widget.job.tags.map((tag) => _buildInfoChip(context, tag)).toList(),
    );
  }

  // Reusable chip widget from previous refactoring
  Widget _buildInfoChip(BuildContext context, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      // Adjusted padding
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        // Use theme color
        borderRadius: BorderRadius.circular(15), // More rounded
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer, // Use theme color
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Consistent spacing
      child: Row(
        children: [
          Icon(icon, color: theme.hintColor, size: 18), // Use theme hint color
          const SizedBox(width: 12),
          Expanded(
            // Allow text to wrap
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescription(TextTheme textTheme) {
    return Text(
      widget.job.description,
      style: textTheme.bodyLarge?.copyWith(height: 1.6), // Adjust line height
    );
  }

  Widget _buildBulletedList(
      List<String> items, TextTheme textTheme, String emptyText) {
    if (items.isEmpty) {
      return Text(emptyText,
          style: textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).hintColor));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // Add padding to align bullet point better
                padding: const EdgeInsets.only(top: 6.0, right: 8.0),
                child: Icon(Icons.circle,
                    size: 6, color: Theme.of(context).hintColor),
              ),
              Expanded(
                child: Text(
                  item,
                  style: textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocation(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: theme.hintColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.job.location,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        // Optional: Add a map icon/button here
      ],
    );
  }

  Widget _buildHrInfo(ThemeData theme, TextTheme textTheme) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Icon(Icons.person_outline,
            color: theme.colorScheme.onSecondaryContainer),
      ),
      title: Text(widget.job.hrName, style: textTheme.titleMedium),
      subtitle: Text('在线',
          style: textTheme.bodyMedium?.copyWith(color: Colors.green)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomCommunicateButton(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: MediaQuery.of(context).padding.bottom +
                12.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            String peerIdForChat = widget.job.id;
            _isInitiatingChat ? null : _handleInitiateChat();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  peerName: widget.job.hrName,
                  peerId: peerIdForChat,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: _isInitiatingChat
              ? Container(
                  // Show loading indicator inside button
                  width: 20,
                  height: 20,
                  margin:
                      const EdgeInsets.only(right: 8), // Add spacing like icon
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Icon(Icons.chat_bubble_outline, color: colorScheme.onPrimary),
          // Use outlined icon
          label: Text(
            _isInitiatingChat ? '请稍候...' : '立即沟通',
            // Change text while loading
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
