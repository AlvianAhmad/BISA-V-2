import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import 'detail_kelas_page.dart';
import 'join_kelas_page.dart';

class KelasPage extends StatelessWidget {
  const KelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinKelasPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: vm.kelasSaya(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum join kelas'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final kelasId = doc['kelasId'];

              return StreamBuilder(
                stream: vm.detailKelas(kelasId),
                builder: (_, kelasSnap) {
                  if (!kelasSnap.hasData) return const SizedBox();

                  final data = kelasSnap.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['nama']),
                    subtitle: Text(data['kode']),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailKelasPage(kelasId: kelasId),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
