import 'dart:io';
import 'dart:html' as html;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/models/file_upload_response.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';

class ApiService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<FileUploadResponse> uploadFile(dynamic file) async {
    try {
      late FormData formData;
      
      if (kIsWeb && file is html.File) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoad.first;
        
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            reader.result as List<int>,
            filename: file.name,
          ),
        });
      } else if (file is File) {
        String fileName = file.path.split('/').last;
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
        });
      } else {
        throw Exception('Invalid file type provided');
      }

      final options = await _getAuthOptions();
      final response = await _dio.post(
        '/api/file/upload',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200) {
        return FileUploadResponse.fromJson(response.data);
      } else {
        throw Exception('文件上传失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('文件上传失败: $e');
    }
  }

  Future<Options> _getAuthOptions() async {
    String? authToken = await _storage.read(key: 'authToken');
    Options options = Options();
    if (authToken != null && authToken.isNotEmpty) {
      options.headers = {'Authorization': 'Bearer $authToken'};
    }
    return options;
  }

  Future<List<UserFile>> fetchUserFiles() async {
    const url = '/user/my-files';
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
    const url = '/commonPhrases/list';
    debugPrint("Fetching common phrases for user $userId from $url...");
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'userId': userId},
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
    const url = '/chat/history';

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
        List<Map<String, dynamic>> historyData = List<Map<String, dynamic>>.from(
            (response.data['data'] as List).whereType<Map<String, dynamic>>());
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

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final url = '/user/profile';

    debugPrint("Fetching user profile from $url...");
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(url, options: options);

      debugPrint("Fetch profile response status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data['data'] is Map<String, dynamic>) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        debugPrint(
            "Failed to load profile, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法加载用户信息 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint("Unauthorized (401) fetching profile. Token might be invalid.");
        throw Exception("请先登录 (401)");
      }
      debugPrint("DioError fetching profile: ${e.message}");
      debugPrint("DioError response: ${e.response?.data}");
      throw Exception("加载用户信息失败: ${e.message ?? '网络请求错误'}");
    } catch (e) {
      debugPrint("Unexpected error fetching profile: $e");
      throw Exception("加载用户信息时发生未知错误");
    }
  }
}