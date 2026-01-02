// ========================= absensi_page.dart =========================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class AbsensiPage extends StatelessWidget {
  final String kelasNama;

  const AbsensiPage({super.key, required this.kelasNama});

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    // format sederhana: 2026-01-02 13:45
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  DateTime _extractTanggal(Map<String, dynamic> data) {
    final raw = data['tanggal'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vm.absensiByKelasNama(kelasNama),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada absensi'));
          }

          // ✅ ambil list, lalu SORTING di client agar tidak butuh index Firestore
          final list = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final da = _extractTanggal(a.data());
              final db = _extractTanggal(b.data());
              return db.compareTo(da); // terbaru dulu (descending)
            });

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final doc = list[index];
              final d = doc.data();

              final judul = (d['judul'] ?? '-').toString();
              final aktif = (d['aktif'] ?? false) == true;

              final tanggal = _extractTanggal(d);
              final jamMulai = (d['jamMulai'] ?? '').toString();
              final jamSelesai = (d['jamSelesai'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(judul),
                  subtitle: Text(
                    '${_formatTanggal(tanggal)}'
                    ' • $jamMulai - $jamSelesai'
                    ' • ${aktif ? 'Aktif' : 'Nonaktif'}',
                  ),
                  trailing: FutureBuilder<bool>(
                    future: vm.sudahAbsen(doc.id),
                    builder: (context, s) {
                      if (s.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final sudah = s.data ?? false;

                      return ElevatedButton(
                        onPressed: (!aktif || sudah)
                            ? null
                            : () => vm.absen(doc.id),
                        child: Text(
                          sudah
                              ? 'Sudah Hadir'
                              : (aktif ? 'Hadir' : 'Nonaktif'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
