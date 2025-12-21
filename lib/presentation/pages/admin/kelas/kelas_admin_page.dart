import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';
import '../materi/materi_admin_page.dart';
import 'tambah_kelas_page.dart';
import 'edit_kelas_page.dart';

class KelasPage extends StatelessWidget {
  const KelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KelasViewModel>();
    final kelasList = vm.kelasList;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Kelas')),
      body: kelasList.isEmpty
          ? const Center(child: Text('Belum ada kelas'))
          : ListView.builder(
              itemCount: kelasList.length,
              itemBuilder: (context, index) {
                final kelas = kelasList[index];
                return ListTile(
                  title: Text(kelas.nama),
                  subtitle: Text('${kelas.jurusan} - ${kelas.semester}'),

                  // 🔥 INI YANG PENTING
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MateriPage(
                          kelasId: kelas.id,
                          kelasNama: kelas.nama,
                        ),
                      ),
                    );
                  },

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditKelasPage(kelas: kelas),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => vm.hapusKelas(kelas.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahKelasPage()),
        ),
      ),
    );
  }
}
