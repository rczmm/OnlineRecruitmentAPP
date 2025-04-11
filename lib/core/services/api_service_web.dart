// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zhaopingapp/core/models/file_upload_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

// Web implementation for ApiService
extension ApiServiceWeb on ApiService {
  // No longer needed as we're using direct file upload
  Future<FileUploadResponse> uploadWebFile(html.File file) async {
    try {
      final xhr = html.HttpRequest();
      xhr.open('POST', '/api/file/upload', async: true);
      
      const storage = FlutterSecureStorage();
      final authToken = await storage.read(key: 'authToken');
      // Only set necessary headers, let browser handle multipart/form-data
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      xhr.responseType = 'json';
      if (authToken != null) {
        xhr.setRequestHeader('Authorization', 'Bearer $authToken');
      }
      xhr.setRequestHeader('Accept', 'application/json');
      
      final completer = Completer<FileUploadResponse>();
      
      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          Map<String, dynamic> jsonResponse;
          try {
            jsonResponse = Map<String, dynamic>.from(xhr.response as Map);
          } catch (e) {
            jsonResponse = {
              'success': true,
              'message': 'Upload successful',
              'fileUrl': xhr.responseText
            };
          }
          final response = FileUploadResponse.fromJson(jsonResponse);
          completer.complete(response);
        } else {
          completer.complete(FileUploadResponse(
            success: false,
            msg: 'Upload failed: ${xhr.statusText}',
          ));
        }
      });

      xhr.onError.listen((_) {
        completer.complete(FileUploadResponse(
          success: false,
          msg: 'Upload failed: Network error',
        ));
      });

      // Set up progress tracking
      xhr.upload.onProgress.listen((event) {
        if (event.lengthComputable) {
          final percentComplete = ((event.loaded ?? 0) / (event.total ?? 1) * 100).round();
          debugPrint('Upload progress: $percentComplete%');
        }
      });

      // Create multipart form-data manually
      final boundary = '---------------------------${DateTime.now().millisecondsSinceEpoch}';
      xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=$boundary');

      // Create blob data manually
      final blobParts = <Object>[];
      blobParts.add('--$boundary\r\n');
      blobParts.add('Content-Disposition: form-data; name="file"; filename="${file.name}"\r\n');
      blobParts.add('Content-Type: ${file.type}\r\n\r\n');
      blobParts.add(file);
      blobParts.add('\r\n--$boundary--\r\n');

      xhr.send(html.Blob(blobParts));
      
      return completer.future;
    } catch (e) {
      return FileUploadResponse(
        success: false,
        msg: 'Upload failed: $e',
      );
    }
  }

  // No helper methods needed as we're using native FormData
}