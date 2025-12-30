import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import 'kumpul_tugas_page.dart';

class TugasPage extends StatelessWidget {
  final String kelasId;

  const TugasPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tugas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: vm.tugas(kelasId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada tugas'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['judul']),
                subtitle: Text(data['deskripsi'] ?? ''),
                trailing: ElevatedButton(
                  child: const Text('Kumpul'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KumpulTugasPage(
                          tugasId: doc.id,
                          judulTugas: data['judul'],
                          deskripsi: data['deskripsi'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
