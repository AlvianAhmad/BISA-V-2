import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bisa/presentation/viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class JoinKelasPage extends StatelessWidget {
  const JoinKelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MahasiswaViewModel>();
    final ctrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Join Kelas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(labelText: 'Kode Kelas'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await vm.joinKelas(ctrl.text.trim());
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Gabung'),
            ),
          ],
        ),
      ),
    );
  }
}
