import 'package:flutter/material.dart';

class NetworkPDFViewer extends StatelessWidget {
  final String pdfUrl;

  const NetworkPDFViewer({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络 PDF 查看器'),
      ),
      body: const Center(
        child: Text('网络 PDF 查看器'),
      ),
    );
  }
}
