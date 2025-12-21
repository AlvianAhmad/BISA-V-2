import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

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

  String? selectedKelas;
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    judul = TextEditingController(text: widget.tugas.judul);
    deskripsi = TextEditingController(text: widget.tugas.deskripsi);
    selectedKelas = widget.tugas.kelas;
    deadline = widget.tugas.deadline;
  }

  @override
  void dispose() {
    judul.dispose();
    deskripsi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasVM = context.read<TugasViewModel>();
    final kelasVM = context.watch<KelasViewModel>();

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
                decoration: const InputDecoration(labelText: 'Judul Tugas'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              /// ===== DROPDOWN KELAS =====
              DropdownButtonFormField<String>(
                value: selectedKelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: kelasVM.kelasList
                    .map(
                      (k) => DropdownMenuItem<String>(
                        value: k.nama,
                        child: Text(k.nama),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedKelas = v),
                validator: (v) => v == null ? 'Pilih kelas' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (deadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih deadline tugas')),
                    );
                    return;
                  }

                  await tugasVM.updateTugasItem(
                    Tugas(
                      id: widget.tugas.id,
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                      kelas: selectedKelas!,
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

      /// ===== PICK DEADLINE =====
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}
