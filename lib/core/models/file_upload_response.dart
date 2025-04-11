
class FileUploadResponse {
  final bool success;
  final String msg;
  final String? data;
  final int? code;

  FileUploadResponse({
    required this.success,
    required this.msg,
    this.data,
    this.code,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      success: json['success'] ?? false,
      msg: json['msg'] ?? '',
      data: json['data'],
      code: json['code'],
    );
  }
}