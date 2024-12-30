import 'dart:io'; // 导入io库以进行文件操作（如果需要）
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 导入日期格式化库

class AttachmentResumePage extends StatefulWidget {
  const AttachmentResumePage({super.key});

  @override
  State<AttachmentResumePage> createState() => _AttachmentResumePageState();
}

class _AttachmentResumePageState extends State<AttachmentResumePage> {
  // 模拟PDF文件列表，实际应用中需要从文件系统或服务器获取
  final List<PdfFile> pdfFiles = [
    PdfFile(name: '我的简历1.pdf', size: '1.2MB', lastModified: DateTime.now().subtract(const Duration(days: 1))),
    PdfFile(name: '项目经验.pdf', size: '800KB', lastModified: DateTime.now().subtract(const Duration(days: 7))),
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
        leading: IconButton( // 返回按钮
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('附件简历'),
        actions: [
          IconButton( // 提示按钮
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
            Expanded( // 使用Expanded使列表填充可用空间
              child: ListView.builder(
                itemCount: pdfFiles.length,
                itemBuilder: (context, index) {
                  final file = pdfFiles[index];
                  return Card(
                    child: ListTile(
                      title: Text(file.name),
                      subtitle: Text('${file.size} - ${DateFormat('yyyy-MM-dd HH:mm').format(file.lastModified)}'), // 格式化日期
                      trailing: const Icon(Icons.picture_as_pdf), // PDF图标
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
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 均匀分布按钮
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 上传简历的逻辑
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