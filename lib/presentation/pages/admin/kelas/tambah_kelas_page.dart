import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class TambahKelasPage extends StatefulWidget {
  const TambahKelasPage({super.key});

  @override
  State<TambahKelasPage> createState() => _TambahKelasPageState();
}

class _TambahKelasPageState extends State<TambahKelasPage> {
  final _formKey = GlobalKey<FormState>();
  final nama = TextEditingController();
  final jurusan = TextEditingController();
  final semester = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<KelasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kelas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input('Nama Kelas', nama),
              _input('Jurusan', jurusan),
              _input('Semester', semester),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.tambahKelas(
                    Kelas(
                      id: '',
                      nama: nama.text,
                      jurusan: jurusan.text,
                      semester: semester.text,
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
