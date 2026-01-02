import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import '../materi/materi_page.dart';
import '../tugas/tugas_page.dart';
import '../absensi/absensi_page.dart';
import '../jadwal/jadwal_page.dart';

class DetailKelasPage extends StatelessWidget {
  final String kelasId;

  const DetailKelasPage({super.key, required this.kelasId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kelas')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: vm.detailKelas(kelasId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Kelas tidak ditemukan'));
          }

          final data = snap.data!.data() ?? {};
          final kelasNama = (data['nama'] ?? '').toString();

          if (kelasNama.isEmpty) {
            return const Center(child: Text('Field "nama" kelas kosong'));
          }

          return ListView(
            children: [
              // header kecil biar jelas
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  kelasNama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Divider(height: 1),

              _menu(
                context,
                'Materi',
                Icons.menu_book,
                MateriPage(kelasId: kelasId), // ✅ tetap pakai kelasId
              ),
              _menu(
                context,
                'Tugas',
                Icons.assignment,
                TugasPage(kelasNama: kelasNama), // ✅ tetap pakai kelasId
              ),

              // ✅ Absensi sekarang pakai kelasNama (bukan kelasId)
              _menu(
                context,
                'Absensi',
                Icons.fact_check,
                AbsensiPage(kelasNama: kelasNama),
              ),

              // ✅ Jadwal sekarang pakai kelasNama (bukan kelasId)
              _menu(
                context,
                'Jadwal',
                Icons.schedule,
                JadwalPage(kelasNama: kelasNama),
              ),
            ],
          );
        },
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
