import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<String?> getCurrentUserId() async {
    // Add error handling
    return await _storage.read(key: 'userId');
  }
}
