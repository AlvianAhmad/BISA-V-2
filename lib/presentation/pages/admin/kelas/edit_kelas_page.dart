import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class EditKelasPage extends StatefulWidget {
  final Kelas kelas;
  const EditKelasPage({super.key, required this.kelas});

  @override
  State<EditKelasPage> createState() => _EditKelasPageState();
}

class _EditKelasPageState extends State<EditKelasPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nama;
  late final TextEditingController jurusan;
  late final TextEditingController semester;

  @override
  void initState() {
    super.initState();
    nama = TextEditingController(text: widget.kelas.nama);
    jurusan = TextEditingController(text: widget.kelas.jurusan);
    semester = TextEditingController(text: widget.kelas.semester);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<KelasViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Kelas')),
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

                  await vm.editKelas(
                    Kelas(
                      id: widget.kelas.id,
                      nama: nama.text,
                      jurusan: jurusan.text,
                      semester: semester.text,
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
