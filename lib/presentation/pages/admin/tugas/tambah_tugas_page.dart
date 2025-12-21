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

  List<String> kelasItems = [];

  @override
  void initState() {
    super.initState();
    final kelasVM = context.read<KelasViewModel>();
    kelasVM.kelasStream().listen((kelasList) {
      setState(() {
        kelasItems = kelasList.map((k) => k.nama).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tugasVM = context.read<TugasViewModel>();

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

                  await tugasVM.tambahTugas(
                    Tugas(
                      id: '',
                      judul: judul.text,
                      deskripsi: deskripsi.text,
                      kelas: selectedKelas!,
                      deadline: deadline!,
                    ),
                  );

                  if (!mounted) return;
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
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
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
