import 'package:dio/dio.dart';
import '../models/chat.dart';
import '../services/dio_client.dart';

class ChatService {
  final Dio _dio = dio;

  // 获取聊天列表
  Future<List<Chat>> getChatList() async {
    try {
      // 发起网络请求获取聊天列表
      final response = await _dio.get('/api/chats');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Chat.fromJson(json)).toList();
      } else {
        // 请求成功但状态码不是200
        print('获取聊天列表失败: ${response.statusCode}');
        return _getDefaultChatList();
      }
    } catch (e) {
      // 请求失败，返回默认聊天列表
      print('获取聊天列表异常: $e');
      return _getDefaultChatList();
    }
  }

  // 获取默认聊天列表
  List<Chat> _getDefaultChatList() {
    return [
      Chat(
        id: '1101',
        name: '小凤神',
        lastMessage: '圣诞快乐！',
        avatarUrl: 'https://example.com/avatar1.jpg',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Chat(
        id: '111',
        name: '用户B',
        lastMessage: '最近怎么样？',
        avatarUrl: 'https://example.com/avatar2.jpg',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Chat(
        id: '123456',
        name: '用户C',
        lastMessage: '好久不见！',
        avatarUrl: 'https://example.com/avatar3.jpg',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}