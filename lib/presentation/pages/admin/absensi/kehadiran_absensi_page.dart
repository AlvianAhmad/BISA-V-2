import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// pakai theme sama (copy dari absensi_admin_page)
const Color kAbsensiPrimary = Color(0xFF0E2E72);
const Color kAbsensiPrimary2 = Color(0xFF1B3C9E);
const Color kAbsensiBg = Color(0xFFF5F6FA);
const Color kAbsensiTextDark = Color(0xFF1A2552);
const Color kAbsensiMuted = Color(0xFF6F7AA6);

class KehadiranAbsensiPage extends StatefulWidget {
  final String absensiId;
  final String judul;
  final String kelas;

  const KehadiranAbsensiPage({
    super.key,
    required this.absensiId,
    required this.judul,
    required this.kelas,
  });

  @override
  State<KehadiranAbsensiPage> createState() => _KehadiranAbsensiPageState();
}

class _KehadiranAbsensiPageState extends State<KehadiranAbsensiPage> {
  int tab = 0; // 0: Hadir, 1: Belum

  @override
  Widget build(BuildContext context) {
    final hadirStream = FirebaseFirestore.instance
        .collection('absensi')
        .doc(widget.absensiId)
        .collection('hadir')
        .orderBy('waktu', descending: true)
        .snapshots();

    final kelasMahasiswaStream = FirebaseFirestore.instance
        .collection('kelas_mahasiswa')
        .where('kelasId', isEqualTo: widget.kelas)
        .snapshots();

    return Scaffold(
      backgroundColor: kAbsensiBg,
      appBar: AppBar(
        backgroundColor: kAbsensiPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kehadiran Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: hadirStream,
          builder: (context, hadirSnap) {
            if (hadirSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (hadirSnap.hasError) {
              return _Info(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat',
                subtitle: '${hadirSnap.error}',
              );
            }

            final hadirDocs = hadirSnap.data?.docs ?? [];
            final hadirIds = hadirDocs.map((e) => e.id).toSet();

            // kalau mau "belum hadir", kita butuh daftar mahasiswa di kelas tsb.
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: kelasMahasiswaStream,
              builder: (context, kelasSnap) {
                if (kelasSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (kelasSnap.hasError) {
                  return _Info(
                    icon: Icons.error_outline_rounded,
                    title: 'Gagal memuat kelas',
                    subtitle: '${kelasSnap.error}',
                  );
                }

                final kmDocs = kelasSnap.data?.docs ?? [];
                final mahasiswaIds = kmDocs
                    .map((d) => (d.data()['mahasiswaId'] ?? '').toString())
                    .where((x) => x.isNotEmpty)
                    .toList();

                final belumIds = mahasiswaIds
                    .where((id) => !hadirIds.contains(id))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  children: [
                    _HeaderInfo(
                      judul: widget.judul,
                      kelas: widget.kelas,
                      totalKelas: mahasiswaIds.length,
                      totalHadir: hadirDocs.length,
                      totalBelum: belumIds.length,
                    ),
                    const SizedBox(height: 12),

                    _Tabs(
                      tab: tab,
                      onChange: (v) => setState(() => tab = v),
                      hadir: hadirDocs.length,
                      belum: belumIds.length,
                    ),
                    const SizedBox(height: 12),

                    if (tab == 0)
                      _HadirList(docs: hadirDocs)
                    else
                      _BelumList(mahasiswaIds: belumIds),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChange;
  final int hadir;
  final int belum;

  const _Tabs({
    required this.tab,
    required this.onChange,
    required this.hadir,
    required this.belum,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, bool active, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? kAbsensiPrimary.withOpacity(0.10) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: active ? kAbsensiPrimary : kAbsensiMuted,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Hadir ($hadir)', tab == 0, () => onChange(0)),
        const SizedBox(width: 10),
        chip('Belum ($belum)', tab == 1, () => onChange(1)),
      ],
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final String judul;
  final String kelas;
  final int totalKelas;
  final int totalHadir;
  final int totalBelum;

  const _HeaderInfo({
    required this.judul,
    required this.kelas,
    required this.totalKelas,
    required this.totalHadir,
    required this.totalBelum,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: kAbsensiTextDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kelas: $kelas • Total mahasiswa: $totalKelas',
            style: const TextStyle(
              color: kAbsensiMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Pill(
                label: 'Hadir',
                value: '$totalHadir',
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'Belum',
                value: '$totalBelum',
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: kAbsensiTextDark,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _HadirList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  const _HadirList({required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const _Info(
        icon: Icons.inbox_rounded,
        title: 'Belum ada yang hadir',
        subtitle: 'Belum ada mahasiswa yang melakukan absensi.',
      );
    }

    return Column(
      children: docs.map((d) {
        final data = d.data();
        final nama = (data['nama'] ?? '-').toString();
        final nim = (data['nim'] ?? data['npm'] ?? '-').toString();

        final waktu = data['waktu'];
        String waktuStr = '-';
        if (waktu is Timestamp) {
          final dt = waktu.toDate().toLocal();
          String two(int x) => x.toString().padLeft(2, '0');
          waktuStr =
              '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RowCard(
            leadingIcon: Icons.check_circle_rounded,
            leadingColor: const Color(0xFF22C55E),
            title: nama,
            subtitle: 'NIM/NPM: $nim',
            trailing: waktuStr,
          ),
        );
      }).toList(),
    );
  }
}

class _BelumList extends StatelessWidget {
  final List<String> mahasiswaIds;

  const _BelumList({required this.mahasiswaIds});

  @override
  Widget build(BuildContext context) {
    if (mahasiswaIds.isEmpty) {
      return const _Info(
        icon: Icons.verified_rounded,
        title: 'Semua sudah hadir',
        subtitle: 'Semua mahasiswa di kelas ini sudah melakukan absensi.',
      );
    }

    // Ambil profil user untuk tiap id (batched pakai whereIn maksimal 10 per query)
    return _UsersByIds(ids: mahasiswaIds);
  }
}

class _UsersByIds extends StatelessWidget {
  final List<String> ids;

  const _UsersByIds({required this.ids});

  @override
  Widget build(BuildContext context) {
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, (i + 10) > ids.length ? ids.length : i + 10));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchUsers(chunks),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _Info(
            icon: Icons.error_outline_rounded,
            title: 'Gagal memuat mahasiswa',
            subtitle: '${snap.error}',
          );
        }

        final users = snap.data ?? [];
        return Column(
          children: users.map((u) {
            final nama = (u['nama'] ?? u['name'] ?? u['fullname'] ?? '-')
                .toString();
            final nim = (u['nim'] ?? u['npm'] ?? u['NIM'] ?? u['NPM'] ?? '-')
                .toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RowCard(
                leadingIcon: Icons.hourglass_bottom_rounded,
                leadingColor: const Color(0xFFEF4444),
                title: nama,
                subtitle: 'NIM/NPM: $nim',
                trailing: 'Belum',
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUsers(
    List<List<String>> chunks,
  ) async {
    final fs = FirebaseFirestore.instance;
    final out = <Map<String, dynamic>>[];

    for (final c in chunks) {
      final q = await fs
          .collection('users')
          .where(FieldPath.documentId, whereIn: c)
          .get();
      for (final d in q.docs) {
        out.add(d.data());
      }
    }
    // sort by nama biar rapi
    out.sort(
      (a, b) =>
          (a['nama'] ?? '').toString().compareTo((b['nama'] ?? '').toString()),
    );
    return out;
  }
}

class _RowCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _RowCard({
    required this.leadingIcon,
    required this.leadingColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: leadingColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(leadingIcon, color: leadingColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: kAbsensiTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kAbsensiMuted,
                    fontSize: 12.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kAbsensiPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: kAbsensiPrimary,
                fontSize: 11.5,
              ),
            ),
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
                  color: kAbsensiPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: kAbsensiPrimary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: kAbsensiTextDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kAbsensiMuted,
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
