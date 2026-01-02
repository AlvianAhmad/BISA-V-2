import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class JadwalPage extends StatelessWidget {
  final String kelasNama; // ✅ langsung nama kelas

  const JadwalPage({super.key, required this.kelasNama});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vm.jadwalByKelasNama(kelasNama), // ✅ langsung query jadwal
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error jadwal: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada jadwal'));
          }

          final list = snapshot.data!.docs;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final d = list[index].data();

              final mataKuliah = (d['mataKuliah'] ?? '-').toString();
              final hari = (d['hari'] ?? '-').toString();
              final jam = (d['jam'] ?? '-').toString();
              final dosen = (d['dosen'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(mataKuliah),
                  subtitle: Text(
                    [
                      '$hari • $jam',
                      if (dosen.isNotEmpty) 'Dosen: $dosen',
                    ].join('\n'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
