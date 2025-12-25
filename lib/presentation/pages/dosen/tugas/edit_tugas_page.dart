import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';

class EditTugasPage extends StatefulWidget {
  final Tugas tugas;
  const EditTugasPage({super.key, required this.tugas});

  @override
  State<EditTugasPage> createState() => _EditTugasPageState();
}

class _EditTugasPageState extends State<EditTugasPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController judul;
  late TextEditingController deskripsi;
  DateTime? deadline;
  String? kelas;

  @override
  void initState() {
    super.initState();
    judul = TextEditingController(text: widget.tugas.judul);
    deskripsi = TextEditingController(text: widget.tugas.deskripsi);
    kelas = widget.tugas.kelas;
    deadline = widget.tugas.deadline;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TugasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: kelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
                onChanged: (v) => kelas = v,
                validator: (v) => v!.isEmpty ? 'Kelas wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (deadline == null) return;

                  await vm.updateTugasItem(
                    Tugas(
                      id: widget.tugas.id, // ❗ wajib
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                      kelas: kelas!,
                      deadline: deadline!,
                    ),
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.calendar_month),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: deadline ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() => deadline = picked);
          }
        },
      ),
    );
  }
}
