import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileReaderService {
  Future<String?> pickAndReadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result == null) return null;

    final file = File(result.files.single.path!);
    final ext = result.files.single.extension?.toLowerCase();

    switch (ext) {
      case 'pdf':
        return _readPdf(file);
      case 'txt':
        return file.readAsString();
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
