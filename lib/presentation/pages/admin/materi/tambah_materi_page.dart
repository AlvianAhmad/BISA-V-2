import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/admin/materi/materi_view_model.dart';

class TambahMateriPage
    extends
        StatefulWidget {
  final String kelasId;
  final String kelasNama;
  final List<
    String
  >
  pertemuanList;

  const TambahMateriPage({
    super.key,
    required this.kelasId,
    required this.kelasNama,
    required this.pertemuanList,
  });

  @override
  State<
    TambahMateriPage
  >
  createState() => _TambahMateriPageState();
}

class _TambahMateriPageState
    extends
        State<
          TambahMateriPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final judul = TextEditingController();
  final deskripsi = TextEditingController();

  PlatformFile? pickedFile;
  String? fileUrl;
  String? fileType;

  Future<
    void
  >
  pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'png',
      ],
    );

    if (result !=
        null) {
      pickedFile = result.files.first;
      fileType = pickedFile!.extension;

      final ref = FirebaseStorage.instance.ref(
        'materi/${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}',
      );

      final upload = await ref.putData(
        pickedFile!.bytes!,
      );
      fileUrl = await upload.ref.getDownloadURL();

      setState(
        () {},
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          MateriViewModel
        >();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Materi',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judul,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                ),
                validator:
                    (
                      v,
                    ) => v!.isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                ),
                validator:
                    (
                      v,
                    ) => v!.isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.upload,
                ),
                label: const Text(
                  'Upload PDF / Gambar',
                ),
                onPressed: pickAndUpload,
              ),
              if (fileUrl !=
                  null)
                const Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                    'File berhasil diupload',
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.tambahMateri(
                    Materi(
                      id: '',
                      kelasId: widget.kelasId,
                      kelasNama: widget.kelasNama,
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                      fileUrl: fileUrl,
                      fileType: fileType,
                      createdAt: DateTime.now(),
                    ),
                  );

                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Simpan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
