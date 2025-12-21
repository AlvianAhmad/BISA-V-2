import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/jadwal.dart';
import '../../../viewmodels/admin/jadwal/jadwal_view_model.dart';
import 'tambah_jadwal_page.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<JadwalViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahJadwalPage()),
              );
            },
          ),
        ],
      ),

      // 🔥 INI KUNCI UTAMA
      body: StreamBuilder<List<Jadwal>>(
        stream: vm.jadwalStream(),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Belum ada jadwal'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final jadwal = data[i];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    jadwal.mataKuliah,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${jadwal.dosen}\n${jadwal.kelas} • ${jadwal.hari} • ${jadwal.jam}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await vm.deleteJadwal(jadwal.id);
                    },
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
