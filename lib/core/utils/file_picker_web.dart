// @dart=2.19
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';

class FilePickerWeb {
  static Future<html.File?> pickFile() async {
    if (!kIsWeb) return null;
    
    final input = html.FileUploadInputElement()..accept = '.pdf,.doc,.docx';
    input.click();

    final completer = Completer<html.File?>();
    input.onChange.listen((event) {
      final files = input.files;
      if (files?.isNotEmpty ?? false) {
        completer.complete(files![0]);
      } else {
        completer.complete(null);
      }
    });

    input.onError.listen((event) {
      completer.complete(null);
    });

    return completer.future;
  }
}