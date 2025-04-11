import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:zhaopingapp/core/models/file_upload_response.dart';
import 'package:zhaopingapp/core/utils/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zhaopingapp/core/services/api_service_platform.dart';
import 'package:zhaopingapp/core/permissions/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zhaopingapp/widgets/NetworkPDFViewer.dart';

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (bytes == 0)
      ? 0
      : (decimals == 0
          ? (bytes.toString().length - 1) ~/ 3
          : (bytes.bitLength - 1) ~/ 10);
  i = (bytes == 0) ? 0 : ((bytes.bitLength - 1) ~/ 10);
  if (i >= suffixes.length) i = suffixes.length - 1;
  return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
}

class AttachmentResumePage extends StatefulWidget {
  const AttachmentResumePage({super.key});

  @override
  State<AttachmentResumePage> createState() => _AttachmentResumePageState();
}

class _AttachmentResumePageState extends State<AttachmentResumePage> {
  final List<PdfFile> _pdfFiles = [
    PdfFile(
        name: '我的简历1.pdf',
        sizeInBytes: 1258291, // ~1.2MB
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        url:
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'),
    PdfFile(
        name: '项目经验.pdf',
        sizeInBytes: 819200, // 800KB
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
        // Replace with actual URL
        url: 'https://www.africau.edu/images/default/sample.pdf'),
  ];

  bool _isLoading = false;

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('温馨提示'),
          content:
              const Text('最多支持上传三份简历。\n文件格式支持 PDF、DOC、DOCX。\n单文件大小不超过 10MB。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadResume() async {
    if (_pdfFiles.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('最多只能上传3份简历')),
        );
      }
      return;
    }

    if (!kIsWeb) {
      bool hasPermission = await StoragePermission.request();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要存储权限才能选择文件')),
          );
        }
        return;
      }
    }

    String fileName = '';
    int fileSize = 0;
    dynamic fileData;

    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          withData: true,
        );
        if (result == null || result.files.isEmpty) {
          return;
        }

        PlatformFile webFile = result.files.first;

        if (webFile.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('无法读取Web文件内容，请重试')),
            );
          }
          return;
        }
        fileName = webFile.name;
        fileSize = webFile.size;
        fileData = webFile;
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );

        if (result == null || result.files.single.path == null) {
          return;
        }

        File file = File(result.files.single.path!);
        fileName = result.files.single.name;
        fileSize = await file.length();
        fileData = file;
      }

      const maxSize = 10 * 1024 * 1024;
      if (fileSize > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('文件大小不能超过 ${formatBytes(maxSize, 0)}')),
          );
        }
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final apiService = ApiService();
      FileUploadResponse response;

      response = await apiService.uploadFile(fileData);

      if (!mounted) return;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _pdfFiles.add(PdfFile(
              name: fileName,
              sizeInBytes: fileSize,
              lastModified: DateTime.now(),
              url: response.data!,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('上传成功')),
          );
        }
      } else {
        String errorMessage = response.msg ?? '上传失败，请稍后重试';
        debugPrint('上传失败: $errorMessage (Code: ${response.code})');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      debugPrint('上传或选择文件时出错: $e');
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '操作失败: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('附件简历'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHintDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_pdfFiles.isEmpty)
              const Expanded(
                child: Center(child: Text('您还没有上传任何附件简历。')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _pdfFiles.length,
                  itemBuilder: (context, index) {
                    final file = _pdfFiles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      // Add some vertical spacing
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf,
                            color: Colors.redAccent), // Leading icon
                        onTap: () {
                          // Ensure the URL is not empty before navigating
                          if (file.url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Pass the actual URL of the selected file
                                builder: (context) =>
                                    NetworkPDFViewer(pdfUrl: file.url),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('无法预览：文件URL无效')),
                            );
                          }
                        },
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // Prevent long names from breaking layout
                        ),
                        subtitle: Text(
                            '${formatBytes(file.sizeInBytes, 1)} - ${DateFormat('yyyy-MM-dd HH:mm').format(file.lastModified)}'),
                        // Add a delete button?
                        // trailing: IconButton(
                        //   icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                        //   onPressed: () {
                        //     // TODO: Implement delete functionality
                        //     _showDeleteConfirmationDialog(index);
                        //   },
                        // ),
                      ),
                    );
                  },
                ),
              ),
            const Divider(height: 20), // Add a visual separator
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '支持 PDF、DOC、DOCX 格式，单文件不超过 10MB。',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('上传简历'),
                  onPressed: _pdfFiles.length < 3 ? _uploadResume : null,
                  // Disable if limit reached
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    // Disable button visually if needed
                    backgroundColor: _pdfFiles.length < 3 ? null : Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('制作新简历'),
                  onPressed: () {
                    // TODO: Navigate to or implement the resume creation feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('“制作新简历”功能暂未开放')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}

class PdfFile {
  final String name;
  final int sizeInBytes;
  final DateTime lastModified;
  final String url;

  PdfFile({
    required this.name,
    required this.sizeInBytes,
    required this.lastModified,
    required this.url,
  });
}
