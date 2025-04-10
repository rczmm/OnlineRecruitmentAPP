import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:zhaopingapp/core/utils/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zhaopingapp/core/services/api_service_platform.dart';
import 'package:zhaopingapp/core/permissions/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zhaopingapp/widgets/NetworkPDFViewer.dart';

class AttachmentResumePage extends StatefulWidget {
  const AttachmentResumePage({super.key});

  @override
  State<AttachmentResumePage> createState() => _AttachmentResumePageState();
}

class _AttachmentResumePageState extends State<AttachmentResumePage> {
  final List<PdfFile> pdfFiles = [
    PdfFile(
        name: '我的简历1.pdf',
        size: '1.2MB',
        lastModified: DateTime.now().subtract(const Duration(days: 1))),
    PdfFile(
        name: '项目经验.pdf',
        size: '800KB',
        lastModified: DateTime.now().subtract(const Duration(days: 7))),
    PdfFile(name: '求职信.pdf', size: '500KB', lastModified: DateTime.now()),
  ];

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('温馨提示'),
          content: const Text('最多支持上传三份简历。'),
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
            Expanded(
              child: ListView.builder(
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  final file = pdfFiles[index];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NetworkPDFViewer(
                                    pdfUrl: "https://arxiv.org/pdf/2502.10215")));
                      },
                      title: Text(file.name),
                      subtitle: Text(
                          '${file.size} - ${DateFormat('yyyy-MM-dd HH:mm').format(file.lastModified)}'),
                      trailing: const Icon(Icons.picture_as_pdf),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('最多支持上传三份简历。'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool hasPermission = await StoragePermission.request();
                    if (!hasPermission) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('需要存储权限才能上传文件')),
                        );
                      }
                      return;
                    }

                    try {
                      if (kIsWeb) {
                        final webFile = await FilePickerWeb.pickFile();
                        if (webFile != null && mounted) {
                          // Handle web file upload
                          final fileName = webFile.name;
                          final fileSize = webFile.size;
                          
                          if (fileSize > 10 * 1024 * 1024) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('文件大小不能超过10MB')),
                            );
                            return;
                          }

                          if (pdfFiles.length >= 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('最多只能上传3份简历')),
                            );
                            return;
                          }

                          // Show loading indicator
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          final apiService = ApiService();
                          
                          // Create a mock File-like object for the web
                          final response = await apiService.uploadWebFile(webFile);

                          if (!mounted) return;
                          Navigator.pop(context); // Remove loading indicator

                          if (response.success && response.fileUrl != null) {
                            setState(() {
                              pdfFiles.add(PdfFile(
                                name: fileName,
                                size: '${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB',
                                lastModified: DateTime.now(),
                              ));
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('上传成功')),
                            );
                          } else {
                            debugPrint('上传失败: ${response.message}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('上传失败: ${response.message}')),
                            );
                          }
                        }
                      } else {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                        );

                        if (result != null && mounted) {
                          File file = File(result.files.single.path!);
                        
                        int fileSize = await file.length();
                        if (fileSize > 10 * 1024 * 1024) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('文件大小不能超过10MB')),
                          );
                          return;
                        }

                        if (pdfFiles.length >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('最多只能上传3份简历')),
                          );
                          return;
                        }

                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        final apiService = ApiService();
                        final response = await apiService.uploadFile(file);

                        if (!mounted) return;
                        Navigator.pop(context);

                        if (response.success && response.fileUrl != null) {
                          setState(() {
                            pdfFiles.add(PdfFile(
                              name: result.files.single.name,
                              size: '${(fileSize / 1024).round()}KB',
                              lastModified: DateTime.now(),
                            ));
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('上传成功')),
                          );
                        } else {
                          debugPrint('上传失败: ${response.message}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('上传失败: ${response.message}')),
                          );
                        }
                      }
                    }
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(context);
                      debugPrint('上传失败: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('上传失败: $e')),
                      );
                    }
                  },
                  child: const Text('上传简历'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 制作新简历的逻辑
                  },
                  child: const Text('制作新简历'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PdfFile {
  final String name;
  final String size;
  final DateTime lastModified;

  PdfFile({required this.name, required this.size, required this.lastModified});
}