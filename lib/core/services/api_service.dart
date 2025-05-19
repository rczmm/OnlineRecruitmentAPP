import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart' show PlatformFile;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/models/file_upload_response.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/features/chat/data/models/chat_message_model.dart';

class ApiService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<FileUploadResponse> uploadFile(dynamic fileData) async {
    // Log entry point and the type of data received
    debugPrint(
        "ApiService.uploadFile: Entered. Received data type: ${fileData?.runtimeType}");

    if (fileData == null) {
      debugPrint("ApiService.uploadFile: Error - Received null fileData.");
      throw Exception("Cannot upload null file data.");
    }

    try {
      late MultipartFile multipartFile;
      String? uploadFilename;

      // --- Type Handling ---
      if (fileData is File) {
        String filePath = fileData.path;
        if (filePath.isEmpty) {
          throw Exception("File path is empty.");
        }
        uploadFilename = filePath.split('/').last;
        debugPrint(
            "ApiService.uploadFile: Creating MultipartFile from file...");
        multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: uploadFilename,
        );
      } else if (fileData is PlatformFile) {
        uploadFilename = fileData.name;
        Uint8List? fileBytes = fileData.bytes;

        if (fileBytes == null) {
          throw Exception(
              "PlatformFile bytes are null. Ensure 'withData: true' was used during picking.");
        }
        if (uploadFilename.isEmpty) {
          throw Exception("PlatformFile name is empty.");
        }
        multipartFile = MultipartFile.fromBytes(
          fileBytes, // Use the bytes from PlatformFile
          filename: uploadFilename,
        );
      } else {
        throw Exception(
            'Invalid file data type provided: ${fileData.runtimeType}');
      }

      debugPrint("ApiService.uploadFile: Creating FormData...");
      FormData formData = FormData.fromMap({
        'file': multipartFile, // Key 'file' must match backend expectation
      });
      debugPrint("ApiService.uploadFile: FormData created.");

      debugPrint("ApiService.uploadFile: Getting auth options...");
      final options = await _getAuthOptions();
      debugPrint(
          "ApiService.uploadFile: Auth options received. Making POST request to /api/file/upload...");

      final response = await _dio.post(
        '/file/upload', // Your endpoint
        data: formData,
        options: options,
        onSendProgress: (int sent, int total) {},
      );
      debugPrint(
          "ApiService.uploadFile: POST request completed. Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        debugPrint(
            "ApiService.uploadFile: Upload successful. Parsing response.");
        return FileUploadResponse.fromJson(response.data);
      } else {
        throw DioError(
          // Throw a DioError for consistency if status is not 200
          requestOptions: response.requestOptions,
          response: response,
          type: DioErrorType.badResponse,
          error: 'Upload failed with status ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      // Catch Dio specific errors
      throw Exception('网络或服务器错误: ${e.response?.statusCode ?? e.message}');
    } catch (e, s) {
      throw Exception('文件上传处理出错: $e'); // Rethrow
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
        List<Map<String, dynamic>> historyData =
            List<Map<String, dynamic>>.from((response.data['data'] as List)
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

  Future<Map<String, dynamic>> fetchUserProfile() async {
    const url = '/user/profile';

    debugPrint("Fetching user profile from $url...");
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(url, options: options);

      debugPrint("Fetch profile response status: ${response.statusCode}");

      if (response.statusCode == 200 &&
          response.data['data'] is Map<String, dynamic>) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        debugPrint(
            "Failed to load profile, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法加载用户信息 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint(
            "Unauthorized (401) fetching profile. Token might be invalid.");
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

  /// 接受面试邀请
  Future<bool> acceptInterviewInvitation({
    required String interviewId,
    required String senderId,
  }) async {
    const url = '/interview/accept';

    debugPrint(
        "Accepting interview invitation: $interviewId from sender: $senderId");
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        url,
        queryParameters: {'id': interviewId},
        options: options,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
            "Failed to accept interview, status: ${response.statusCode}, data: ${response.data}");
        throw Exception("无法接受面试邀请 (错误码: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("DioError accepting interview: ${e.message}");
      debugPrint("DioError response: ${e.response?.data}");
      throw Exception("接受面试邀请失败: ${e.message ?? '网络请求错误'}");
    } catch (e) {
      debugPrint("Unexpected error accepting interview: $e");
      throw Exception("接受面试邀请时发生未知错误");
    }
  }
}
