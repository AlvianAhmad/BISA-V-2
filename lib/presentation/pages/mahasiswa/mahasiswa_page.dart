import 'package:flutter/material.dart';
import 'kelas/kelas_page.dart';
import 'materi/materi_page.dart';
import 'tugas/tugas_page.dart';
import 'absensi/absensi_page.dart';
import 'jadwal/jadwal_page.dart';
import 'lexa/lexa_chat_page.dart';

class MahasiswaPage extends StatelessWidget {
  const MahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ sementara hardcode, nanti ambil dari kelas yang di-join
    const kelasId = 'kelas_1';

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Mahasiswa')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _menu(context, 'Kelas', Icons.class_, const KelasPage()),

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

          _menu(context, 'LEXA', Icons.smart_toy, const LexaChatPage()),
        ],
      ),
    );
  }

  Widget _menu(BuildContext c, String t, IconData i, Widget p) {
    return InkWell(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => p)),
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 36),
            const SizedBox(height: 8),
            Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
