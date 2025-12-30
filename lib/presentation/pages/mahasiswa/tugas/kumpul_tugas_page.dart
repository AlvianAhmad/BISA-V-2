import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class KumpulTugasPage extends StatelessWidget {
  final String tugasId;
  final String judulTugas;
  final String deskripsi;

  const KumpulTugasPage({
    super.key,
    required this.tugasId,
    required this.judulTugas,
    required this.deskripsi,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(judulTugas)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<bool>(
          future: vm.sudahKumpul(tugasId),
          builder: (_, snapshot) {
            final sudah = snapshot.data ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deskripsi),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: sudah
                      ? null
                      : () async {
                          await vm.kumpulTugas(tugasId);
                          Navigator.pop(context);
                        },
                  child: Text(sudah ? 'Sudah Dikumpulkan' : 'Kumpulkan Tugas'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
