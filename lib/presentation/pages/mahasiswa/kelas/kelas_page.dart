// lib/presentation/pages/mahasiswa/kelas/kelas_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail_kelas_page.dart';
import 'join_kelas_page.dart'; // ✅ TAMBAH INI

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

  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final db = FirebaseFirestore.instance;

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
          'Daftar Kelas',
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

      // ✅ TOMBOL AMBIL / GABUNG KELAS BARU
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => const JoinKelasPage(),
            ),
          );
          // list akan otomatis update karena StreamBuilder
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
          StreamBuilder<
            QuerySnapshot<
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
                .snapshots(),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      [];

                  // filter kelas master (bukan doc join)
                  final kelasMaster = docs.where(
                    (
                      doc,
                    ) {
                      final d = doc.data();
                      final hasNama =
                          d['nama'] !=
                          null;

                      final isJoinDoc =
                          d['mahasiswaId'] !=
                              null ||
                          d['joinedAt'] !=
                              null ||
                          d['type'] ==
                              'join';

                      return hasNama &&
                          !isJoinDoc;
                    },
                  ).toList();

                  // search filter
                  final q = _search.text.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? kelasMaster
                      : kelasMaster.where(
                          (
                            doc,
                          ) {
                            final d = doc.data();
                            final nama =
                                (d['nama'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();
                            final jurusan =
                                (d['jurusan'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();
                            final kode =
                                (d['kode'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();
                            final semester =
                                (d['semester'] ??
                                        '')
                                    .toString()
                                    .toLowerCase();

                            return nama.contains(
                                  q,
                                ) ||
                                jurusan.contains(
                                  q,
                                ) ||
                                kode.contains(
                                  q,
                                ) ||
                                semester.contains(
                                  q,
                                );
                          },
                        ).toList();

                  return CustomScrollView(
                    slivers: [
                      // SEARCH BAR
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            2,
                            16,
                            14,
                          ),
                          child: _SearchBar(
                            controller: _search,
                            onChanged:
                                (
                                  _,
                                ) => setState(
                                  () {},
                                ),
                          ),
                        ),
                      ),

                      // EMPTY STATE
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              q.isEmpty
                                  ? 'Belum ada kelas'
                                  : 'Kelas tidak ditemukan',
                              style: const TextStyle(
                                color: _muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                      // LIST
                      if (filtered.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (
                              context,
                              index,
                            ) {
                              final doc = filtered[index];
                              final d = doc.data();

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

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  14,
                                ),
                                child: _KelasModernCard(
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              _,
                                            ) => DetailKelasPage(
                                              kelasId: doc.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 90,
                        ),
                      ), // ruang utk FAB
                    ],
                  );
                },
          ),
    );
  }
}

/// ======================
/// SEARCH BAR MODERN
/// ======================
class _SearchBar
    extends
        StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<
    String
  >
  onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.78,
            ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: const Color(
                0x14000000,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x0F000000,
                ),
                blurRadius: 18,
                offset: Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(
                  0xFF6F7AA6,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari kelas...',
                    hintStyle: TextStyle(
                      color: Color(
                        0xFF6F7AA6,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(
                      0xFF1A2552,
                    ),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged(
                      '',
                    );
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  color: const Color(
                    0xFF6F7AA6,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================
/// CARD KELAS MODERN (lebih menarik)
/// - bagian dosen dibuat chip, bukan kotak
/// - ada chip semester
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
              // soft circles
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

              // subtle gloss
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

              // content
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
                    // Title + badge kode
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

                    // ✅ Prodi / Jurusan (baris sendiri)
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

                    // ✅ Semester (baris bawahnya)
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

                    // ✅ Chips dosen + semester (lebih menarik)
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
