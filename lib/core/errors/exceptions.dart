import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class ApiException extends AppException {
  final dynamic code;

  ApiException(super.message, [this.code]);

  @override
  String toString() =>
      'ApiException: $message ${code != null ? "(Code: $code)" : ""}';
}

class NetworkException extends AppException {
  final DioException? dioError;

  NetworkException(super.message, {this.dioError});

  String get friendlyMessage {
    if (dioError != null) {
      switch (dioError!.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return '网络连接超时，请检查你的网络连接并重试。';
        case DioExceptionType.badResponse:
          return '服务器似乎开小差了 (${dioError!.response?.statusCode})，请稍后重试。';
        case DioExceptionType.connectionError:
          return '网络连接错误，请检查你的网络设置。';
        case DioExceptionType.cancel:
          return '请求已取消。';
        default:
          return '网络请求失败，请重试。 ($message)';
      }
    }
    return message;
  }

  factory NetworkException.fromDioError(DioException dioError) {
    String message;
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout";
        break;
      case DioExceptionType.badResponse:
        message = "Bad response (${dioError.response?.statusCode})";
        break;
      case DioExceptionType.connectionError:
        message = "Connection error";
        break;
      case DioExceptionType.cancel:
        message = "Request cancelled";
        break;
      default:
        message = "Network error: ${dioError.message}";
        break;
    }
    return NetworkException(message, dioError: dioError);
  }

  @override
  String toString() =>
      'NetworkException: $message ${dioError != null ? "(DioError: ${dioError!.type})" : ""}';
}

class DataParsingException extends AppException {
  DataParsingException(String message) : super('数据处理错误: $message');
}
