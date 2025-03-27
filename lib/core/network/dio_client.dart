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
      // 连接超时时间，5 秒
      connectTimeout: const Duration(milliseconds: 5000),
      // 接收超时时间，3 秒
      receiveTimeout: const Duration(milliseconds: 3000),
    ));

    Future<String?> getAuthToken() async {
      final token = await _storage.read(key: 'authToken');
      return token;
    }

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authToken = await getAuthToken();
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 在响应返回后执行的操作，例如处理响应数据
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // 在发生错误时执行的操作，例如显示错误提示
        return handler.next(e);
      },
    ));
  }
}

// 获取 Dio 实例的便捷方法
final dio = DioClient().dio;
