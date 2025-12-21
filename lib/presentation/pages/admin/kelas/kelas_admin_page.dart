import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';
import 'tambah_kelas_page.dart';
import 'edit_kelas_page.dart';

class KelasPage extends StatelessWidget {
  const KelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KelasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Kelas')),
      body: StreamBuilder<List<Kelas>>(
        stream: vm.kelasStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final kelasList = snapshot.data!;
          if (kelasList.isEmpty)
            return const Center(child: Text('Belum ada kelas'));

          return ListView.builder(
            itemCount: kelasList.length,
            itemBuilder: (context, index) {
              final kelas = kelasList[index];
              return ListTile(
                title: Text(kelas.nama),
                subtitle: Text('${kelas.jurusan} - ${kelas.semester}'),
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
