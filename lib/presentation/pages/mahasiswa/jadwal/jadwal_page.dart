import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class JadwalPage extends StatelessWidget {
  final String kelasId;

  const JadwalPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal')),
      body: StreamBuilder(
        stream: vm.jadwal(kelasId), // ✅ FIX
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada jadwal'));
          }

          final list = snapshot.data!.docs;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final d = list[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(d['mataKuliah']),
                  subtitle: Text('${d['hari']} • ${d['jam']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
