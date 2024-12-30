import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/zhaoping/',
      // 替换为你的 API 基础 URL，例如：'https://api.example.com'
      connectTimeout: const Duration(milliseconds: 5000),
      // 连接超时时间，5 秒
      receiveTimeout: const Duration(milliseconds: 3000), // 接收超时时间，3 秒
    ));

    // 添加拦截器 (可选，但强烈推荐)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求发送前执行的操作，例如添加 token
        // options.headers['Authorization'] = 'Bearer your_token';
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options); // 继续请求
      },
      onResponse: (response, handler) {
        // 在响应返回后执行的操作，例如处理响应数据
        print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response); // 继续处理响应
      },
      onError: (DioError e, handler) {
        // 在发生错误时执行的操作，例如显示错误提示
        print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e); // 继续抛出错误
      },
    ));
  }
}

// 获取 Dio 实例的便捷方法
final dio = DioClient().dio;
