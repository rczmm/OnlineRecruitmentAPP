// Implementation for non-web platforms
import 'package:zhaopingapp/core/models/file_upload_response.dart';

import 'api_service.dart';

extension ApiServiceIO on ApiService {
  Future<FileUploadResponse> uploadWebFile(dynamic file) async {
    throw UnsupportedError('uploadWebFile is only available on web platform');
  }
}