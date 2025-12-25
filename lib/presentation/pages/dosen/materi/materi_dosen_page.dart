import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/admin/materi/materi_view_model.dart';
import 'tambah_materi_page.dart';
import 'edit_materi_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriPage extends StatelessWidget {
  final String kelasId;
  final String kelasNama;

  const MateriPage({super.key, required this.kelasId, required this.kelasNama});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MateriViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Materi $kelasNama')),
      body: StreamBuilder<List<Materi>>(
        stream: vm.materiStream(kelasId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada materi'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final m = list[i];
              return Card(
                child: ListTile(
                  title: Text(m.judul),
                  subtitle: Text(m.deskripsi),
                  leading: Icon(
                    m.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                  ),
                  onTap: m.fileUrl == null
                      ? null
                      : () => launchUrl(Uri.parse(m.fileUrl!)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditMateriPage(materi: m),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => vm.hapusMateri(m.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TambahMateriPage(kelasId: kelasId, kelasNama: kelasNama),
            ),
          );
        },
      ),
    );
  }
}
