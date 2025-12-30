import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/admin/materi/materi_view_model.dart';

class EditMateriPage
    extends
        StatefulWidget {
  final Materi materi;
  const EditMateriPage({
    super.key,
    required this.materi,
  });

  @override
  State<
    EditMateriPage
  >
  createState() => _EditMateriPageState();
}

class _EditMateriPageState
    extends
        State<
          EditMateriPage
        > {
  late TextEditingController judul;
  late TextEditingController deskripsi;

  @override
  void initState() {
    super.initState();
    judul = TextEditingController(
      text: widget.materi.judul,
    );
    deskripsi = TextEditingController(
      text: widget.materi.deskripsi,
    );
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
          'Edit Materi',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            TextField(
              controller: judul,
            ),
            TextField(
              controller: deskripsi,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await vm.editMateri(
                  Materi(
                    id: widget.materi.id,
                    kelasId: widget.materi.kelasId,
                    kelasNama: widget.materi.kelasNama,
                    judul: judul.text,
                    deskripsi: deskripsi.text,
                    fileUrl: widget.materi.fileUrl,
                    fileType: widget.materi.fileType,
                    createdAt: widget.materi.createdAt,
                  ),
                );
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
