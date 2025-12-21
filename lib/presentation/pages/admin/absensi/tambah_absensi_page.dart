import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';

class TambahAbsensiPage extends StatefulWidget {
  const TambahAbsensiPage({super.key});

  @override
  State<TambahAbsensiPage> createState() => _TambahAbsensiPageState();
}

class _TambahAbsensiPageState extends State<TambahAbsensiPage> {
  final _formKey = GlobalKey<FormState>();

  final judul = TextEditingController();
  final kelas = TextEditingController();
  final jamMulai = TextEditingController();
  final jamSelesai = TextEditingController();

  DateTime tanggal = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AbsensiViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Sesi Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input('Judul Absensi', judul),
              _input('Kelas', kelas),
              _input('Jam Mulai (08:00)', jamMulai),
              _input('Jam Selesai (10:00)', jamSelesai),
              const SizedBox(height: 12),

              ListTile(
                title: Text(
                  'Tanggal: ${tanggal.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
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

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.tambahAbsensi(
                    Absensi(
                      id: '',
                      judul: judul.text,
                      kelas: kelas.text,
                      tanggal: tanggal,
                      jamMulai: jamMulai.text,
                      jamSelesai: jamSelesai.text,
                      aktif: true,
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
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v!.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
