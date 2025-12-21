import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/jadwal.dart';
import '../../../viewmodels/admin/jadwal/jadwal_view_model.dart';

class EditJadwalPage extends StatefulWidget {
  final Jadwal jadwal;
  const EditJadwalPage({super.key, required this.jadwal});

  @override
  State<EditJadwalPage> createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
  late TextEditingController mataKuliah;
  late TextEditingController dosen;
  late TextEditingController kelas;
  late TextEditingController hari;
  late TextEditingController jam;

  @override
  void initState() {
    super.initState();
    mataKuliah = TextEditingController(text: widget.jadwal.mataKuliah);
    dosen = TextEditingController(text: widget.jadwal.dosen);
    kelas = TextEditingController(text: widget.jadwal.kelas);
    hari = TextEditingController(text: widget.jadwal.hari);
    jam = TextEditingController(text: widget.jadwal.jam);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<JadwalViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Jadwal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                await vm.updateJadwal(
                  Jadwal(
                    id: widget.jadwal.id,
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
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
