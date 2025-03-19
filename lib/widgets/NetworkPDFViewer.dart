import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NetworkPDFViewer extends StatelessWidget {
  final String pdfUrl;

  const NetworkPDFViewer({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络 PDF 查看器'),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
      ),
    );
  }
}
