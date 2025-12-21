import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/jadwal.dart';
import '../../../viewmodels/admin/jadwal/jadwal_view_model.dart';

class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final _formKey = GlobalKey<FormState>();

  final mataKuliah = TextEditingController();
  final dosen = TextEditingController();
  final kelas = TextEditingController();
  final hari = TextEditingController();
  final jam = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<JadwalViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Jadwal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input('Mata Kuliah', mataKuliah),
              _input('Dosen', dosen),
              _input('Kelas', kelas),
              _input('Hari', hari),
              _input('Jam', jam),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.tambahJadwal(
                    Jadwal(
                      id: '',
                      mataKuliah: mataKuliah.text,
                      dosen: dosen.text,
                      kelas: kelas.text,
                      hari: hari.text,
                      jam: jam.text,
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
