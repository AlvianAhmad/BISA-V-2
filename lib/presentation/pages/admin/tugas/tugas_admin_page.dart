import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';
import 'tambah_tugas_page.dart';

class TugasPage extends StatelessWidget {
  const TugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TugasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: StreamBuilder<List<Tugas>>(
        stream: vm.tugasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('Belum ada tugas'));

          final tugasList = snapshot.data!;
          return ListView.builder(
            itemCount: tugasList.length,
            itemBuilder: (context, index) {
              final tugas = tugasList[index];
              return ListTile(
                title: Text(tugas.judul),
                subtitle: Text('${tugas.kelas} - ${tugas.deadline.toLocal()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await vm.hapusTugas(tugas.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahTugasPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
