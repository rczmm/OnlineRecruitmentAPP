import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/network/api_constants.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/models/chat.dart';

class ChatService {
  final Dio _dio = dio;

  // 获取聊天列表
  Future<List<Chat>> getChatList() async {
    try {
      final String? userId = await FlutterSecureStorage().read(key: 'userId');

      // 发起网络请求获取聊天列表
      final response =
          await _dio.get('/chat/list', queryParameters: {'userId': userId});

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Chat.fromJson(json)).toList();
      } else {
        debugPrint('获取聊天列表失败: ${response.statusCode}');
        return _getDefaultChatList();
      }
    } catch (e) {
      debugPrint('获取聊天列表异常: $e');
      return _getDefaultChatList();
    }
  }

  // 获取默认聊天列表
  List<Chat> _getDefaultChatList() {
    return [
      Chat(
        id: '1101',
        name: '用户A',
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

  Future<bool> initiateChat({
    required String senderId,
    required String receiverId,
    String? jobId,
  }) async {
    try {
      String endpoint = ApiConstants.initiateChat;

      final response = await dio.post(
        endpoint,
        data: {
          ApiRequestKeys.senderId: senderId,
          ApiRequestKeys.receiverId: receiverId,
          if (jobId != null) ApiRequestKeys.jobId: jobId,
        },
        // Add authentication headers if required
      );

      // Check backend response for success (adapt to your API)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally parse conversation ID or other data from response.data
        debugPrint(
            'Chat initiated successfully between $senderId and $receiverId.');
        return true;
      } else {
        debugPrint(
            'Failed to initiate chat: ${response.statusCode} ${response.data}');
        // Optionally throw ApiException based on response.data['message']
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioError initiating chat: $e');
      // Optionally throw NetworkException.fromDioError(e);
      return false;
    } catch (e) {
      debugPrint('Error initiating chat: $e');
      return false;
    }
  }
}
