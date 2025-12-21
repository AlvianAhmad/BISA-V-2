import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';
import 'tambah_absensi_page.dart';
import 'edit_absensi_page.dart';

class AbsensiPage extends StatelessWidget {
  const AbsensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AbsensiViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sesi Absensi')),
      body: StreamBuilder<List<Absensi>>(
        stream: vm.absensiStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada sesi absensi'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final a = list[index];
              return ListTile(
                title: Text(a.judul),
                subtitle: Text('${a.kelas}\n${a.jamMulai} - ${a.jamSelesai}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: a.aktif,
                      onChanged: (v) {
                        vm.updateAbsensi(a.copyWith(aktif: v));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditAbsensiPage(absensi: a),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => vm.hapusAbsensi(a.id),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAbsensiPage()),
          );
        },
      ),
    );
  }
}
