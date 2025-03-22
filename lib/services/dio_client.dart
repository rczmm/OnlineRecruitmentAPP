import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  final _storage = FlutterSecureStorage();

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8088/',
      // 替换为你的 API 基础 URL，例如：'https://api.example.com'
      connectTimeout: const Duration(milliseconds: 5000),
      // 连接超时时间，5 秒
      receiveTimeout: const Duration(milliseconds: 3000), // 接收超时时间，3 秒
    ));

    Future<String?> getAuthToken() async {
      final token = await _storage.read(key: 'authToken');
      return token;
    }

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 在请求发送前执行的操作，例如添加 token
        final authToken = await getAuthToken(); // 等待 Future 完成并获取 token

        if (authToken != null) {
          options.headers['Authorization'] =
              'Bearer $authToken'; // 确保添加 Bearer 前缀（如果你的后端需要）
        }
        return handler.next(options); // 继续请求
      },
      onResponse: (response, handler) {
        // 在响应返回后执行的操作，例如处理响应数据
        return handler.next(response); // 继续处理响应
      },
      onError: (DioError e, handler) {
        // 在发生错误时执行的操作，例如显示错误提示
        return handler.next(e); // 继续抛出错误
      },
    ));
  }
}

// 获取 Dio 实例的便捷方法
final dio = DioClient().dio;
