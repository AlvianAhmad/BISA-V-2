import 'package:flutter/material.dart';
import '../materi/materi_page.dart';
import '../tugas/tugas_page.dart';
import '../absensi/absensi_page.dart';
import '../jadwal/jadwal_page.dart';

class DetailKelasPage extends StatelessWidget {
  final String kelasId;

  const DetailKelasPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kelas')),
      body: ListView(
        children: [
          _menu(
            context,
            'Materi',
            Icons.menu_book,
            MateriPage(kelasId: kelasId),
          ),
          _menu(
            context,
            'Tugas',
            Icons.assignment,
            TugasPage(kelasId: kelasId),
          ),
          _menu(
            context,
            'Absensi',
            Icons.fact_check,
            AbsensiPage(kelasId: kelasId),
          ),
          _menu(
            context,
            'Jadwal',
            Icons.schedule,
            JadwalPage(kelasId: kelasId),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
