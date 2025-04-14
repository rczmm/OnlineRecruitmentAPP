import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:zhaopingapp/features/profile/data/models/user_profile_model.dart';

class UserProfileService {
  final _storage = const FlutterSecureStorage();

  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = await _storage.read(key: 'userId');
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final response = await dio.get(
        '/userProfile',
        queryParameters: {'id': userId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserProfile.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      rethrow;
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final userId = await _storage.read(key: 'userId');
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final data = profile.toJson();
      // 确保userId存在
      data['userId'] = userId;

      final response = await dio.post(
        '/userProfile',
        data: data,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      rethrow;
    }
  }
}
