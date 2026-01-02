import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import 'kumpul_tugas_page.dart';

class TugasPage extends StatelessWidget {
  final String kelasNama;
  const TugasPage({super.key, required this.kelasNama});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tugas')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vm.tugasByKelasNama(kelasNama),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada tugas\n(kelas="$kelasNama")',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final judul = (data['judul'] ?? '-').toString();
              final deskripsi = (data['deskripsi'] ?? '').toString();

              return ListTile(
                title: Text(judul),
                subtitle: Text(deskripsi),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KumpulTugasPage(
                          tugasId: doc.id,
                          judulTugas: judul,
                          deskripsi: deskripsi,
                        ),
                      ),
                    );
                  },
                  child: const Text('Kumpul'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
