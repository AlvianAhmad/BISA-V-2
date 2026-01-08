// lib/presentation/pages/mahasiswa/kelas/kelas_page.dart
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'detail_kelas_page.dart';
import 'join_kelas_page.dart';

class _RelJoinKelas {
  final String relId;
  final String kelasId;
  const _RelJoinKelas({
    required this.relId,
    required this.kelasId,
  });
}

class KelasPage
    extends
        StatefulWidget {
  const KelasPage({
    super.key,
  });

  @override
  State<
    KelasPage
  >
  createState() => _KelasPageState();
}

class _KelasPageState
    extends
        State<
          KelasPage
        > {
  static const Color _bg = Color(
    0xFFF5F6FA,
  );
  static const Color _textDark = Color(
    0xFF1A2552,
  );
  static const Color _muted = Color(
    0xFF6F7AA6,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final db = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          color: _textDark,
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Kelas Saya',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: const [
          SizedBox(
            width: 10,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final joined =
              await Navigator.push<
                bool
              >(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => const JoinKelasPage(),
                ),
              );

          if (joined ==
                  true &&
              context.mounted) {
            _showTopToast(
              context,
              message: 'Berhasil gabung kelas',
            );
          }
        },
        icon: const Icon(
          Icons.group_add_rounded,
        ),
        label: const Text(
          'Gabung Kelas',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color(
          0xFF1B3C9E,
        ),
        foregroundColor: Colors.white,
        elevation: 10,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body:
          (uid ==
              null)
          ? const Center(
              child: Text(
                'Kamu belum login.',
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : StreamBuilder<
              DocumentSnapshot<
                Map<
                  String,
                  dynamic
                >
              >
            >(
              // ambil user buat tahu primaryKelasId (opsional)
              stream: db
                  .collection(
                    'users',
                  )
                  .doc(
                    uid,
                  )
                  .snapshots(),
              builder:
                  (
                    context,
                    userSnap,
                  ) {
                    if (userSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (userSnap.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${userSnap.error}',
                        ),
                      );
                    }

                    final userData =
                        userSnap.data?.data() ??
                        {};

                    // ✅ ini kunci multi kelas:
                    // ambil semua relasi kelas_mahasiswa untuk uid
                    return StreamBuilder<
                      QuerySnapshot<
                        Map<
                          String,
                          dynamic
                        >
                      >
                    >(
                      stream: db
                          .collection(
                            'kelas_mahasiswa',
                          )
                          .where(
                            'mahasiswaId',
                            isEqualTo: uid,
                          )
                          .snapshots(),
                      builder:
                          (
                            context,
                            relSnap,
                          ) {
                            if (relSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (relSnap.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${relSnap.error}',
                                ),
                              );
                            }

                            final relDocs =
                                relSnap.data?.docs ??
                                [];

                            if (relDocs.isEmpty) {
                              return const _EmptyPrimaryKelas();
                            }

                            // kumpulkan semua kelasId dari relasi
                            final kelasIds = relDocs
                                .map(
                                  (
                                    e,
                                  ) =>
                                      (e.data()['kelasId'] ??
                                              '')
                                          .toString(),
                                )
                                .where(
                                  (
                                    id,
                                  ) => id.isNotEmpty,
                                )
                                .toList();

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                110,
                              ),
                              children: [
                                // info kecil

                                // render tiap kelasId -> ambil detail kelas -> card
                                ...List.generate(
                                  kelasIds.length,
                                  (
                                    index,
                                  ) {
                                    final kelasId = kelasIds[index];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child:
                                          StreamBuilder<
                                            DocumentSnapshot<
                                              Map<
                                                String,
                                                dynamic
                                              >
                                            >
                                          >(
                                            stream: db
                                                .collection(
                                                  'kelas',
                                                )
                                                .doc(
                                                  kelasId,
                                                )
                                                .snapshots(),
                                            builder:
                                                (
                                                  context,
                                                  kelasSnap,
                                                ) {
                                                  if (!kelasSnap.hasData ||
                                                      !kelasSnap.data!.exists) {
                                                    return _BrokenKelasCard(
                                                      kelasId: kelasId,
                                                    );
                                                  }

                                                  final d =
                                                      kelasSnap.data!.data() ??
                                                      {};
                                                  final nama =
                                                      (d['nama'] ??
                                                              '-')
                                                          .toString();
                                                  final jurusan =
                                                      (d['jurusan'] ??
                                                              '')
                                                          .toString();
                                                  final semester =
                                                      (d['semester'] ??
                                                              '')
                                                          .toString();
                                                  final kode =
                                                      (d['kode'] ??
                                                              '')
                                                          .toString();
                                                  final dosen =
                                                      (d['dosen'] ??
                                                              'Dosen')
                                                          .toString();

                                                  final theme = _CardTheme.pick(
                                                    nama,
                                                    index,
                                                  );

                                                  return Stack(
                                                    children: [
                                                      _KelasModernCard(
                                                        title: nama,
                                                        kode: kode.isEmpty
                                                            ? null
                                                            : kode,
                                                        jurusan: jurusan.isEmpty
                                                            ? null
                                                            : jurusan,
                                                        semester: semester.isEmpty
                                                            ? null
                                                            : semester,
                                                        dosen: dosen,
                                                        theme: theme,
                                                        onTap: () async {
                                                          final result = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    _,
                                                                  ) => DetailKelasPage(
                                                                    kelasId: kelasId,
                                                                  ),
                                                            ),
                                                          );

                                                          if (!context.mounted) return;

                                                          if (result
                                                                  is Map &&
                                                              result['deleted'] ==
                                                                  true) {
                                                            _showTopToast(
                                                              context,
                                                              message:
                                                                  (result['message'] ??
                                                                          'Kelas berhasil dihapus')
                                                                      .toString(),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                          ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                    );
                  },
            ),
    );
  }

  void _showTopToast(
    BuildContext context, {
    required String message,
    Color bgColor = const Color(
      0xFF22C55E,
    ),
    IconData icon = Icons.check_circle_rounded,
  }) {
    final overlay = Overlay.of(
      context,
    );
    if (overlay ==
        null)
      return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (
            _,
          ) {
            final top =
                MediaQuery.of(
                  context,
                ).padding.top +
                12;
            return Positioned(
              top: top,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child:
                    TweenAnimationBuilder<
                      double
                    >(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      curve: Curves.easeOutCubic,
                      tween: Tween(
                        begin: 0.0,
                        end: 1.0,
                      ),
                      builder:
                          (
                            context,
                            t,
                            child,
                          ) {
                            return Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  (1 -
                                          t) *
                                      -14,
                                ),
                                child: child,
                              ),
                            );
                          },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(
                            18,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            InkWell(
                              onTap: () => entry.remove(),
                              borderRadius: BorderRadius.circular(
                                999,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(
                                  6,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            );
          },
    );

    overlay.insert(
      entry,
    );

    Future.delayed(
      const Duration(
        seconds: 2,
      ),
      () {
        try {
          entry.remove();
        } catch (
          _
        ) {}
      },
    );
  }
}

class _BrokenKelasCard
    extends
        StatelessWidget {
  final String kelasId;
  const _BrokenKelasCard({
    required this.kelasId,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(
            0x14000000,
          ),
        ),
      ),
      child: Text(
        'Kelas tidak ditemukan / sudah dihapus.\n(ID: $kelasId)',
        style: const TextStyle(
          color: Color(
            0xFF6F7AA6,
          ),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyPrimaryKelas
    extends
        StatelessWidget {
  const _EmptyPrimaryKelas();

  static const Color _muted = Color(
    0xFF6F7AA6,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.class_,
              size: 64,
              color: Color(
                0xFF1B3C9E,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Kamu belum punya Kelas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(
                  0xFF1A2552,
                ),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Tekan tombol “Gabung Kelas” di kanan bawah untuk mengambil kelas pertama kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================
/// CARD KELAS MODERN (punyamu tetap)
/// ======================
class _KelasModernCard
    extends
        StatelessWidget {
  final String title;
  final String? kode;
  final String? jurusan;
  final String? semester;
  final String dosen;

  final _CardTheme theme;
  final VoidCallback onTap;

  const _KelasModernCard({
    required this.title,
    required this.kode,
    required this.jurusan,
    required this.semester,
    required this.dosen,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        26,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          26,
        ),
        child: Container(
          height: 176,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.gradient.first.withOpacity(
                  0.22,
                ),
                blurRadius: 26,
                offset: const Offset(
                  0,
                  18,
                ),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -60,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.12,
                  ),
                  size: 210,
                ),
              ),
              Positioned(
                left: -40,
                bottom: -70,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.08,
                  ),
                  size: 240,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(
                          0.10,
                        ),
                        Colors.transparent,
                        Colors.black.withOpacity(
                          0.06,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20.5,
                              height: 1.12,
                            ),
                          ),
                        ),
                        if (kode !=
                                null &&
                            kode!.isNotEmpty) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          _Badge(
                            text: kode!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (jurusan !=
                            null &&
                        jurusan!.isNotEmpty)
                      Text(
                        jurusan!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.92,
                          ),
                          fontWeight: FontWeight.w800,
                          fontSize: 13.6,
                        ),
                      )
                    else
                      Text(
                        '-',
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.85,
                          ),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.6,
                        ),
                      ),
                    const SizedBox(
                      height: 6,
                    ),
                    if (semester !=
                            null &&
                        semester!.isNotEmpty)
                      Text(
                        'Semester $semester',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.90,
                          ),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.2,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.person_rounded,
                            text: dosen,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _MiniActionChip(
                          icon: Icons.chevron_right_rounded,
                          onTap: onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip
    extends
        StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.16,
        ),
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white.withOpacity(
              0.92,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.95,
                ),
                fontWeight: FontWeight.w900,
                fontSize: 13.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionChip
    extends
        StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniActionChip({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white.withOpacity(
        0.18,
      ),
      borderRadius: BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.18,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(
              0.92,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge
    extends
        StatelessWidget {
  final String text;
  const _Badge({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.18,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SoftCircle
    extends
        StatelessWidget {
  final Color color;
  final double size;

  const _SoftCircle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// ======================
/// THEME PICKER
/// ======================
class _CardTheme {
  final List<
    Color
  >
  gradient;
  final String? illustrationAsset;
  final IconData fallbackIcon;

  const _CardTheme({
    required this.gradient,
    required this.illustrationAsset,
    required this.fallbackIcon,
  });

  static _CardTheme pick(
    String nama,
    int index,
  ) {
    final n = nama.toLowerCase();

    if (n.contains(
      'web',
    )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF2D7FF9,
          ),
          Color(
            0xFF0E2E72,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.language_rounded,
      );
    }
    if (n.contains(
          'wira',
        ) ||
        n.contains(
          'usaha',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF2E9E67,
          ),
          Color(
            0xFF167A52,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.trending_up_rounded,
      );
    }
    if (n.contains(
          'literasi',
        ) ||
        n.contains(
          'digital',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFFFF9F2E,
          ),
          Color(
            0xFFF26B3A,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.auto_stories_rounded,
      );
    }
    if (n.contains(
          'jaringan',
        ) ||
        n.contains(
          'komputer',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF6A5CFF,
          ),
          Color(
            0xFF1B3C9E,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.dns_rounded,
      );
    }

    const themes = [
      _CardTheme(
        gradient: [
          Color(
            0xFF2D7FF9,
          ),
          Color(
            0xFF0E2E72,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFF2E9E67,
          ),
          Color(
            0xFF167A52,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFFFF9F2E,
          ),
          Color(
            0xFFF26B3A,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFF6A5CFF,
          ),
          Color(
            0xFF1B3C9E,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
    ];

    return themes[index %
        themes.length];
  }
}
