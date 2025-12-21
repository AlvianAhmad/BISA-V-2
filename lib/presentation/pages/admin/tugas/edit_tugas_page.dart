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
  DateTime? deadline;
  String? selectedKelas;

  List<String> kelasItems = [];

  @override
  void initState() {
    super.initState();
    final kelasVM = context.read<KelasViewModel>();

    // Ambil list kelas
    kelasVM.kelasStream().listen((kelasList) {
      setState(() {
        kelasItems = kelasList.map((k) => k.nama).toList();
      });
    });

    // Pre-fill data tugas
    judul = TextEditingController(text: widget.tugas.judul);
    deskripsi = TextEditingController(text: widget.tugas.deskripsi);
    selectedKelas = widget.tugas.kelas;
    deadline = widget.tugas.deadline;
  }

  @override
  Widget build(BuildContext context) {
    final tugasVM = context.read<TugasViewModel>();

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
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                controller: deskripsi,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedKelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: kelasItems
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => selectedKelas = v),
                validator: (v) => v == null ? 'Pilih kelas' : null,
              ),
              const SizedBox(height: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: deadline ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (picked != null) setState(() => deadline = picked);
        },
        child: const Icon(Icons.calendar_today),
      ),
    );
  }
}
