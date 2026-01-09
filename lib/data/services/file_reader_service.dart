import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';

class FileReaderService {
  Future<Map<String, String>?> pickAndReadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
      withData: false,
    );

    if (result == null) return null;

    final picked = result.files.single;
    final path = picked.path;
    if (path == null) return null;

    final file = File(path);
    final ext = picked.extension?.toLowerCase();
    final name = picked.name;

    switch (ext) {
      case 'pdf':
        final text = _readPdf(file);
        debugPrint('PDF "$name" extracted len=${text.length}');
        return {'name': name, 'content': text};

      case 'txt':
        final text = await file.readAsString();
        debugPrint('TXT "$name" read len=${text.length}');
        return {'name': name, 'content': text};

      default:
        return null;
    }
  }

  String _readPdf(File file) {
    final bytes = file.readAsBytesSync();
    final doc = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(doc).extractText();
    doc.dispose();
    return text;
  }
}
