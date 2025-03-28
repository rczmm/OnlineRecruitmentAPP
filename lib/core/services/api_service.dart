import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart'; // Assuming this exists

class ApiService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Options> _getAuthOptions() async {
    String? authToken = await _storage.read(key: 'authToken');
    Options options = Options();
    if (authToken != null && authToken.isNotEmpty) {
      options.headers = {'Authorization': 'Bearer $authToken'};
    }
    return options;
  }

  Future<List<UserFile>> fetchUserFiles() async {
    final url = '/user/my-files';
    debugPrint("Fetching user files from $url...");
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(url, options: options);

      debugPrint("Fetch files response status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data is List) {
        List<UserFile> files = (response.data as List)
            .where((item) =>
                item is Map<String, dynamic> &&
                item['fileName'] != null &&
                item['fileUrl'] != null)
            .map((item) => UserFile.fromJson(item))
            .toList();
        debugPrint("Fetched ${files.length} files.");
        return files;
      } else {
        debugPrint(
            "Failed to load files, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法加载文件列表 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("DioError fetching files: $e");
      throw Exception("加载文件列表失败: ${e.message}");
    } catch (e) {
      debugPrint("Error fetching files: $e");
      throw Exception("加载文件列表时发生未知错误");
    }
  }

  Future<List<CommonPhrase>> fetchCommonPhrases(String userId) async {
    final url = '/commonPhrases/list'; // Correct endpoint
    debugPrint("Fetching common phrases for user $userId from $url...");
    try {
      // Common phrases might not need auth depending on API design, adjust if needed
      // final options = await _getAuthOptions();
      final response = await _dio.get(
        url,
        queryParameters: {'userId': userId},
        // options: options, // Uncomment if auth is needed
      );

      debugPrint("Fetch phrases response status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data?['data'] is List) {
        List<CommonPhrase> phrases = (response.data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => CommonPhrase.fromJson(item))
            .toList();
        debugPrint("Fetched ${phrases.length} common phrases.");
        return phrases;
      } else {
        debugPrint(
            "Failed to load phrases, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法加载常用语 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("DioError fetching common phrases: $e");
      throw Exception("加载常用语失败: ${e.message}");
    } catch (e) {
      debugPrint("Error fetching common phrases: $e");
      throw Exception("加载常用语时发生未知错误");
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory({
    required String sendId,
    required String receiveId,
    int limit = 50,
    String? beforeTimestamp,
  }) async {
    final url = '/chat/history';

    final queryParameters = <String, dynamic>{
      'limit': limit,
      'sendId': sendId,
      'receiveId': receiveId,
    };
    if (beforeTimestamp != null) {
      queryParameters['before'] = beforeTimestamp;
    }

    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 200 && response.data['data'] is List) {
        List<Map<String, dynamic>> historyData = List<Map<String, dynamic>>.from((response.data['data'] as List)
                .whereType<Map<String, dynamic>>());
        debugPrint("Fetched ${historyData.length} historical messages.");
        return historyData;
      } else {
        debugPrint(
            "Failed to load history, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法加载聊天记录 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("DioError fetching history: $e");
      throw Exception("加载聊天记录失败: ${e.message}");
    } catch (e) {
      debugPrint("Error fetching history: $e");
      throw Exception("加载聊天记录时发生未知错误");
    }
  }
}
