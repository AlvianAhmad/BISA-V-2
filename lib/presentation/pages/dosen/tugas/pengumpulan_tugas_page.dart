import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // ✅ WAJIB untuk Clipboard

// pakai theme yang sama dari tugas_admin_page.dart
const Color kTugasPrimary = Color(0xFF0E2E72);
const Color kTugasPrimary2 = Color(0xFF1B3C9E);
const Color kTugasBg = Color(0xFFF5F6FA);
const Color kTugasTextDark = Color(0xFF1A2552);
const Color kTugasMuted = Color(0xFF6F7AA6);

class PengumpulanTugasPage extends StatelessWidget {
  final String tugasId;
  final String judulTugas;

  const PengumpulanTugasPage({
    super.key,
    required this.tugasId,
    required this.judulTugas,
  });

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('tugas')
        .doc(tugasId)
        .collection('pengumpulan')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: kTugasBg,
      appBar: AppBar(
        backgroundColor: kTugasPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengumpulan Tugas',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return _Info(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat',
                subtitle: '${snap.error}',
              );
            }

            final docs = snap.data?.docs ?? [];

            if (docs.isEmpty) {
              return _Info(
                icon: Icons.inbox_rounded,
                title: 'Belum ada pengumpulan',
                subtitle:
                    'Belum ada mahasiswa yang mengumpulkan tugas ini.\nTugas: $judulTugas',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _HeaderInfo(
                  judul: judulTugas,
                  tugasId: tugasId,
                  total: docs.length,
                ),
                const SizedBox(height: 12),
                ...docs.map((d) {
                  final data = d.data();
                  final url = (data['url'] ?? '').toString();
                  final catatan = (data['catatan'] ?? '').toString();

                  final nama = (data['nama'] ?? data['mahasiswaNama'] ?? '-')
                      .toString();
                  final nim = (data['nim'] ?? '-').toString();

                  final createdAt = data['createdAt'];
                  DateTime? dt;
                  if (createdAt is Timestamp) dt = createdAt.toDate();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PengumpulanCard(
                      nama: nama,
                      nim: nim,
                      url: url,
                      catatan: catatan,
                      waktu: dt == null ? '-' : _fmt(dt.toLocal()),
                      onCopy: url.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: url));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link disalin')),
                                );
                              }
                            },
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _fmt(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _HeaderInfo extends StatelessWidget {
  final String judul;
  final String tugasId;
  final int total;

  const _HeaderInfo({
    required this.judul,
    required this.tugasId,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: kTugasPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_rounded, color: kTugasPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: kTugasTextDark,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ID: $tugasId • Total kumpul: $total',
                  style: const TextStyle(
                    color: kTugasMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PengumpulanCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String url;
  final String catatan;
  final String waktu;
  final VoidCallback? onCopy;

  const _PengumpulanCard({
    required this.nama,
    required this.nim,
    required this.url,
    required this.catatan,
    required this.waktu,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kTugasPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_rounded, color: kTugasPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: kTugasTextDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nim == '-' ? 'NIM: -' : 'NIM: $nim',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kTugasMuted,
                        fontSize: 12.8,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kTugasPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  waktu,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: kTugasPrimary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Link Drive:',
            style: TextStyle(
              color: kTugasMuted,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            url.isEmpty ? '-' : url,
            style: TextStyle(
              color: url.isEmpty ? kTugasMuted : kTugasPrimary2,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          if (catatan.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Catatan: $catatan',
              style: const TextStyle(
                color: kTugasMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTugasPrimary,
                    side: BorderSide(color: kTugasPrimary.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text(
                    'Copy Link',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Info({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kTugasPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: kTugasPrimary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: kTugasTextDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTugasMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
