import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class StoragePermission {
  static Future<bool> request() async {
    // On web platform, we don't need to request storage permission
    if (kIsWeb) {
      return true;
    }
    if (await Permission.storage.isGranted) {
      return true;
    }
    
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> check() async {
    // On web platform, we don't need to check storage permission
    if (kIsWeb) {
      return true;
    }
    return await Permission.storage.isGranted;
  }
}