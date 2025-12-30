import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class AbsensiPage extends StatelessWidget {
  final String kelasId;

  const AbsensiPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: StreamBuilder(
        stream: vm.absensi(kelasId), // ✅ FIX
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada absensi'));
          }

          final list = snapshot.data!.docs;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final absensi = list[index];

              return ListTile(
                title: Text(absensi['tanggal']),
                subtitle: Text(absensi['status'] ?? 'Belum absen'),
                trailing: FutureBuilder<bool>(
                  future: vm.sudahAbsen(absensi.id),
                  builder: (context, s) {
                    final sudah = s.data ?? false;

                    return ElevatedButton(
                      onPressed: sudah ? null : () => vm.absen(absensi.id),
                      child: Text(sudah ? 'Sudah Hadir' : 'Hadir'),
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
