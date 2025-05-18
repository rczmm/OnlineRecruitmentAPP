import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zhaopingapp/core/services/api_service.dart';
import 'package:zhaopingapp/core/utils/snackbar_util.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';
import 'package:zhaopingapp/widgets/chat_bubble.dart'; // Your chat bubble widget
import 'package:zhaopingapp/features/chat/data/models/interview_status.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageWidget({super.key, required this.message});

  Future<void> _launchFileUrl(BuildContext context) async {
    if (message.fileUrl != null) {
      final Uri uri = Uri.parse(message.fileUrl!);
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $uri');
          _showErrorSnackbar(context, '无法打开文件链接');
        }
      } catch (e) {
        debugPrint('Error launching URL: $e');
        _showErrorSnackbar(context, '打开链接时出错');
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _acceptInterview(BuildContext context,
      Map<String, dynamic> interviewData) async {
    final ApiService apiService = ApiService();
    try {
      debugPrint('Accepting interview invitation... ${interviewData['id']}');

      // 这里应该调用API接受面试邀请
      await apiService.acceptInterviewInvitation(
        interviewId: interviewData['id']?.toString() ?? '',
        senderId: message.senderId,
      );
      if (context.mounted) {
        SnackbarUtil.showSuccess(context, '已接受面试邀请');
      }
    } catch (e) {
      debugPrint('Error accepting interview: $e');
      if (context.mounted) {
        SnackbarUtil.showError(context, '接受面试邀请失败: 你已经接受了这条面试邀请！');
      }
    }
  }

  Widget _buildInterviewCard(BuildContext context,
      Map<String, dynamic> interviewData) {
    // 解析日期时间
    DateTime? interviewDateTime;
    try {
      if (interviewData['datetime'] != null) {
        interviewDateTime =
            DateTime.parse(interviewData['datetime'].toString());
      }
    } catch (e) {
      debugPrint('Error parsing interview datetime: $e');
    }

    // 格式化日期和时间显示
    final dateFormatter = DateFormat('yyyy年MM月dd日');
    final timeFormatter = DateFormat('HH:mm');
    final dateStr = interviewDateTime != null ? dateFormatter.format(
        interviewDateTime) : '未指定日期';
    final timeStr = interviewDateTime != null ? timeFormatter.format(
        interviewDateTime) : '未指定时间';

    // 获取面试时长
    final duration = interviewData['duration']?.toString() ?? '未指定';
    // 获取面试职位
    final position = interviewData['position']?.toString() ?? '未指定职位';
    // 获取面试地点
    final location = interviewData['location']?.toString() ?? '未指定地点';
    // 获取面试说明
    final notes = interviewData['notes']?.toString() ?? '';
    // 获取面试官
    final interviewer = interviewData['interviewer']?.toString() ?? '未指定';
    // 获取路线指引
    final directions = interviewData['directions']?.toString() ?? '';

    // 面试类型
    final isOffline = interviewData['type']?.toString() == 'offline';
    final meetingLink = interviewData['meetingLink']?.toString() ?? '';
    
    // 获取面试状态
    final int statusCode = int.tryParse(interviewData['status']?.toString() ?? '0') ?? 0;
    final InterviewStatus status = InterviewStatus.fromCode(statusCode);

    return Container(
      margin: EdgeInsets.only(
          left: message.isMe ? 60 : 0, right: message.isMe ? 0 : 60),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: message.isMe ? Colors.blue.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.event_available, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '面试邀请',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(),
              Text('职位: $position',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16,
                      color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text(dateStr),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                      Icons.access_time, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Text('$timeStr (约$duration分钟)'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                      isOffline ? Icons.location_on : Icons.videocam,
                      size: 16,
                      color: Colors.grey.shade700
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      isOffline ? location : '线上面试',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (interviewer.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text('面试官: $interviewer'),
                  ],
                ),
              ],
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('备注: $notes', style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade800)),
              ],
              if (directions.isNotEmpty && isOffline) ...[
                const SizedBox(height: 8),
                Text('路线指引: $directions', style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade800)),
              ],
              if (meetingLink.isNotEmpty && !isOffline) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final Uri uri = Uri.parse(meetingLink);
                    if (!await launchUrl(uri)) {
                      if (context.mounted) {
                        SnackbarUtil.showError(context, '无法打开会议链接');
                      }
                    }
                  },
                  child: const Text(
                    '点击加入会议',
                    style: TextStyle(color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (!message.isMe) Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 根据面试状态显示不同的按钮或文本
                  if (status == InterviewStatus.PENDING_RECEIPT)
                    ElevatedButton(
                      onPressed: () => _acceptInterview(context, interviewData),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: const Text('接受邀请'),
                    )
                  else if (status == InterviewStatus.PENDING)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    )
                  else if (status == InterviewStatus.PASSED)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    )
                  else if (status == InterviewStatus.CANCELLED)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    )
                  else if (status == InterviewStatus.FAILED)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 处理面试邀请消息
    if (message.type == 'INTERVIEW_INVITATION' &&
        message.interviewData != null) {
      return _buildInterviewCard(context, message.interviewData!);
    }
    // 处理文件消息
    else if (message.isFile) {
      // Build file message bubble
      return ChatBubble(
        isSender: message.isMe,
        avatarUrl: message.avatarUrl,
        // timestamp: message.timestamp, // Pass timestamp if ChatBubble supports it
        child: InkWell(
          onTap: () => _launchFileUrl(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            // Reduced padding inside InkWell
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, size: 18,
                    color: message.isMe ? Colors.white70 : Colors.black54),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.fileName ?? '附件',
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Prevent long filenames from breaking layout
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Build regular text message bubble
      return ChatBubble(
        message: message.text,
        isSender: message.isMe,
        avatarUrl: message.avatarUrl,
        // timestamp: message.timestamp, // Pass timestamp if ChatBubble supports it
      );
    }
  }
}