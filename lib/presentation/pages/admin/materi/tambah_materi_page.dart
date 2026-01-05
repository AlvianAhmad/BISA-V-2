// lib/presentation/pages/admin/materi/tambah_materi_page.dart
// Versi: pakai LINK GOOGLE DRIVE (tanpa Firebase Storage upload)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/admin/materi/materi_view_model.dart';

class TambahMateriPage extends StatefulWidget {
  final String kelasId;
  final String kelasNama;
  final List<String> pertemuanList;

  const TambahMateriPage({
    super.key,
    required this.kelasId,
    required this.kelasNama,
    required this.pertemuanList,
  });

  @override
  State<TambahMateriPage> createState() => _TambahMateriPageState();
}

class _TambahMateriPageState extends State<TambahMateriPage> {
  final _formKey = GlobalKey<FormState>();

  final judul = TextEditingController();
  final deskripsi = TextEditingController();

  // ✅ PAKAI LINK DRIVE
  final driveLink = TextEditingController();

  // metadata optional (buat tampilan di list/admin detail)
  String? fileUrl; // = drive link (dinormalize)
  String? fileType; // pdf/doc/xls/ppt/drive
  String? fileName; // optional (kalau user isi)
  int? fileSize; // optional (kalau user isi)

  @override
  void dispose() {
    judul.dispose();
    deskripsi.dispose();
    driveLink.dispose();
    super.dispose();
  }

  // ================== VALIDATION ==================

  bool _isProbablyDriveLink(String url) {
    final u = url.trim().toLowerCase();
    if (u.isEmpty) return true; // link optional
    return u.contains('drive.google.com') || u.contains('docs.google.com');
  }

  String? _validateDriveLink(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional

    if (!_isProbablyDriveLink(s)) {
      return 'Masukkan link Google Drive/Docs yang valid';
    }

    final uri = Uri.tryParse(s);
    if (uri == null || !uri.isAbsolute) {
      return 'Link tidak valid';
    }

    return null;
  }

  // ================== NORMALIZE DRIVE URL ==================
  // Biar "view link" jadi lebih usable.
  // - drive file: /file/d/<id>/view -> uc?export=download&id=<id>
  // - docs/sheets/slides: biarkan (tetap bisa dibuka)
  String _normalizeDriveUrl(String url) {
    final u = url.trim();

    // google drive file
    final fileReg = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)\/');
    final m = fileReg.firstMatch(u);
    if (m != null) {
      final id = m.group(1);
      return 'https://drive.google.com/uc?export=download&id=$id';
    }

    // google drive open?id=<id>
    final uri = Uri.tryParse(u);
    if (uri != null) {
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty && u.contains('drive.google.com')) {
        return 'https://drive.google.com/uc?export=download&id=$id';
      }
    }

    return u;
  }

  String _guessTypeFromUrl(String url) {
    final u = url.toLowerCase();

    if (u.contains('.pdf')) return 'pdf';
    if (u.contains('.doc') || u.contains('.docx')) return 'doc';
    if (u.contains('.xls') || u.contains('.xlsx')) return 'xls';
    if (u.contains('.ppt') || u.contains('.pptx')) return 'ppt';

    // Google Docs
    if (u.contains('docs.google.com/document')) return 'doc';
    if (u.contains('docs.google.com/spreadsheets')) return 'xls';
    if (u.contains('docs.google.com/presentation')) return 'ppt';

    // kalau drive tapi tidak kebaca extension, label "drive"
    if (u.contains('drive.google.com')) return 'drive';

    return 'file';
  }

  // ================== UI HELPERS ==================

  IconData _iconForExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'drive':
        return Icons.cloud_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }

  String _fmtBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${units[i]}';
  }

  // ================== SAVE ==================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final rawLink = driveLink.text.trim();
    final normalized = rawLink.isEmpty ? null : _normalizeDriveUrl(rawLink);

    // set metadata
    if (normalized != null) {
      fileUrl = normalized;
      fileType = _guessTypeFromUrl(normalized);
      // fileName & fileSize biarkan optional (kalau user isi manual)
    } else {
      fileUrl = null;
      fileType = null;
      fileName = null;
      fileSize = null;
    }

    final vm = context.read<MateriViewModel>();

    await vm.tambahMateri(
      Materi(
        id: '',
        kelasId: widget.kelasId,
        kelasNama: widget.kelasNama,
        judul: judul.text.trim(),
        deskripsi: deskripsi.text.trim(),
        fileUrl: fileUrl,
        fileType: fileType,
        fileName: (fileName ?? '').trim().isEmpty ? null : fileName!.trim(),
        fileSize: fileSize,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = driveLink.text.trim().isNotEmpty;
    final type = hasLink ? _guessTypeFromUrl(driveLink.text.trim()) : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Materi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                minLines: 2,
                maxLines: 4,
              ),

              const SizedBox(height: 14),

              // ✅ LINK DRIVE
              TextFormField(
                controller: driveLink,
                decoration: const InputDecoration(
                  labelText: 'Link Google Drive (opsional)',
                  hintText:
                      'Contoh: https://drive.google.com/file/d/.../view?usp=sharing',
                ),
                onChanged: (_) => setState(() {}),
                validator: _validateDriveLink,
              ),

              const SizedBox(height: 12),

              // OPTIONAL: nama file (buat tampilan)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama File (opsional)',
                  hintText: 'Contoh: Modul Pertemuan 1',
                ),
                onChanged: (v) => setState(() => fileName = v),
              ),

              const SizedBox(height: 12),

              // OPTIONAL: ukuran file (buat tampilan)
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ukuran File (opsional, dalam byte)',
                  hintText: 'Contoh: 31234',
                ),
                onChanged: (v) {
                  final n = int.tryParse(v.trim());
                  setState(() => fileSize = n);
                },
              ),

              const SizedBox(height: 14),

              // Preview card kalau ada link
              if (hasLink)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FD),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(_iconForExt(type), color: const Color(0xFF0E2E72)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (fileName ?? '').trim().isEmpty
                                  ? 'Link Drive terpasang'
                                  : fileName!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${type.toUpperCase()}'
                              '${(fileSize ?? 0) > 0 ? ' • ${_fmtBytes(fileSize!)}' : ''}',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              driveLink.text.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
