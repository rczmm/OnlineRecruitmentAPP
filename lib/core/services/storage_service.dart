import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // 使用 final 使其在构造后不可变
  final FlutterSecureStorage _storage;

  // 提供一个常量 key
  static const String _authTokenKey = 'authToken';

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: _authTokenKey);
      // 可以在这里添加 token 验证逻辑（比如检查是否过期）
      return token;
    } catch (e) {
      // 处理读取错误，例如记录日志
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
    } catch (e) {
      debugPrint('Error deleting auth token: $e');
    }
  }
}
