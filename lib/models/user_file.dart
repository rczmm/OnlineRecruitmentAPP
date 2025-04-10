class UserFile {
  final String id;
  final String fileName;
  final String fileUrl;

  UserFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
  });

  factory UserFile.fromJson(Map<String, dynamic> json) {
    return UserFile(
      id: json['id'].toString(),
      fileName: json['fileName'].toString(),
      fileUrl: json['fileUrl'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
    };
  }
}