import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class MateriPage extends StatelessWidget {
  final String kelasId;

  const MateriPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Materi')),
      body: StreamBuilder(
        stream: vm.materi(kelasId), // ✅ FIX
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada materi'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(d['judul']),
                  subtitle: Text(d['deskripsi']),
                  trailing: d.data().toString().contains('fileUrl')
                      ? const Icon(Icons.download)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
