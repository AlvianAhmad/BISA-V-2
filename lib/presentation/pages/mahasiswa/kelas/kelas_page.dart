import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_kelas_page.dart';

class KelasPage extends StatelessWidget {
  const KelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kelas')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('kelas')
            .snapshots(), // ✅ jangan pakai filter kode
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          // ✅ Filter hanya kelas master:
          // - punya field 'nama'
          // - BUKAN dokumen join (yang ada mahasiswaId / joinedAt / type=join)
          final kelasMaster = docs.where((doc) {
            final d = doc.data();
            final hasNama = d['nama'] != null;

            final isJoinDoc =
                d['mahasiswaId'] != null ||
                d['joinedAt'] != null ||
                d['type'] == 'join';

            return hasNama && !isJoinDoc;
          }).toList();

          if (kelasMaster.isEmpty) {
            return const Center(child: Text('Belum ada kelas'));
          }

          return ListView.separated(
            itemCount: kelasMaster.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = kelasMaster[index];
              final d = doc.data();

              final kelasId = doc.id;
              final nama = (d['nama'] ?? '-').toString();
              final jurusan = (d['jurusan'] ?? '').toString();
              final semester = (d['semester'] ?? '').toString();

              // ✅ kode optional (karena admin belum nyimpen kode)
              final kode = (d['kode'] ?? '').toString();

              final subtitleParts = <String>[
                if (kode.isNotEmpty) 'Kode: $kode',
                if (jurusan.isNotEmpty) jurusan,
                if (semester.isNotEmpty) 'Semester $semester',
              ];

              return ListTile(
                title: Text(nama),
                subtitle: subtitleParts.isEmpty
                    ? const Text('-')
                    : Text(subtitleParts.join(' • ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailKelasPage(kelasId: kelasId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
