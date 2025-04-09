class FileUploadResponse {
  final bool success;
  final String message;
  final String? fileUrl;

  FileUploadResponse({
    required this.success,
    required this.message,
    this.fileUrl,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      fileUrl: json['fileUrl'],
    );
  }
}