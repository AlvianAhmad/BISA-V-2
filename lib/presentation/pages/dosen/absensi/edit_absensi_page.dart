import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';

class EditAbsensiPage extends StatefulWidget {
  final Absensi absensi;
  const EditAbsensiPage({super.key, required this.absensi});

  @override
  State<EditAbsensiPage> createState() => _EditAbsensiPageState();
}

class _EditAbsensiPageState extends State<EditAbsensiPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController judul;
  late TextEditingController jamMulai;
  late TextEditingController jamSelesai;

  late DateTime tanggal;
  late bool aktif;

  @override
  void initState() {
    super.initState();
    judul = TextEditingController(text: widget.absensi.judul);
    jamMulai = TextEditingController(text: widget.absensi.jamMulai);
    jamSelesai = TextEditingController(text: widget.absensi.jamSelesai);
    tanggal = widget.absensi.tanggal;
    aktif = widget.absensi.aktif;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AbsensiViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: judul,
                decoration: const InputDecoration(labelText: 'Judul Absensi'),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: jamMulai,
                decoration: const InputDecoration(labelText: 'Jam Mulai'),
                validator: (v) => v!.isEmpty ? 'Jam mulai wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: jamSelesai,
                decoration: const InputDecoration(labelText: 'Jam Selesai'),
                validator: (v) => v!.isEmpty ? 'Jam selesai wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Absensi Aktif'),
                value: aktif,
                onChanged: (v) => setState(() => aktif = v),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.updateAbsensi(
                    widget.absensi.copyWith(
                      judul: judul.text,
                      jamMulai: jamMulai.text,
                      jamSelesai: jamSelesai.text,
                      aktif: aktif,
                    ),
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.date_range),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: tanggal,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() => tanggal = picked);
          }
        },
      ),
    );
  }
}
