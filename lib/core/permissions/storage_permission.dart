import 'package:permission_handler/permission_handler.dart';

class StoragePermission {
  static Future<bool> request() async {
    if (await Permission.storage.isGranted) {
      return true;
    }
    
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> check() async {
    return await Permission.storage.isGranted;
  }
}