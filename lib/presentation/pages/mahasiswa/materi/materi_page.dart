import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/mahasiswa/materi_viewmodel.dart';

class MateriPage extends StatelessWidget {
  final String kelasId;
  const MateriPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MateriViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Materi')),
      body: StreamBuilder<List<Materi>>(
        stream: vm.getMateriByKelas(kelasId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final list = snapshot.data ?? const <Materi>[];

          if (list.isEmpty) {
            return const Center(child: Text('Belum ada materi'));
          }

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = list[index];

              final judul = m.judul.isEmpty ? '-' : m.judul;
              final deskripsi = m.deskripsi;
              final hasFile = (m.fileUrl).toString().trim().isNotEmpty;

              return ListTile(
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(judul),
                subtitle: Text(deskripsi),
                trailing: hasFile ? const Icon(Icons.download_rounded) : null,
                onTap: () {
                  // optional: buka detail / download
                },
              );
            },
          );
        },
      ),
    );
  }
}
