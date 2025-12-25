import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class TambahTugasPage extends StatefulWidget {
  const TambahTugasPage({super.key});

  @override
  State<TambahTugasPage> createState() => _TambahTugasPageState();
}

class _TambahTugasPageState extends State<TambahTugasPage> {
  final _formKey = GlobalKey<FormState>();
  final judul = TextEditingController();
  final deskripsi = TextEditingController();
  DateTime? deadline;
  String? selectedKelas;

  @override
  Widget build(BuildContext context) {
    final tugasVM = context.read<TugasViewModel>();
    final kelasVM = context.watch<KelasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedKelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: kelasVM.kelasList
                    .map(
                      (k) =>
                          DropdownMenuItem(value: k.nama, child: Text(k.nama)),
                    )
                    .toList(),
                onChanged: (v) => selectedKelas = v,
                validator: (v) => v == null ? 'Pilih kelas' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (deadline == null) return;

                  await tugasVM.tambahTugas(
                    Tugas(
                      id: '',
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                      kelas: selectedKelas!,
                      deadline: deadline!,
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (d != null) setState(() => deadline = d);
        },
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}
