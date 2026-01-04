// lib/presentation/pages/mahasiswa/kelas/kelas_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_kelas_page.dart';

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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
            ),
            color: _textDark,
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),

      /// ✅ Search bar ikut scroll: SearchBar + List jadi 1 scrollable
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
                      // ======================
                      // SEARCH BAR (IKUT SCROLL)
                      // ======================
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

                      // ======================
                      // EMPTY STATE
                      // ======================
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

                      // ======================
                      // LIST KELAS
                      // ======================
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
                                child: _KelasGradientCard(
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
                                  favorite:
                                      index %
                                          2 ==
                                      0,
                                  onFavoriteTap: () {},
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
                          height: 22,
                        ),
                      ),
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
              0.75,
            ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: const Color(
                0x12000000,
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
/// CARD KELAS GRADIENT (TANPA GAMBAR & TANPA AVATAR)
/// ======================
class _KelasGradientCard
    extends
        StatelessWidget {
  final String title;
  final String? kode;
  final String? jurusan;
  final String? semester;
  final String dosen;

  final _CardTheme theme;

  final bool favorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _KelasGradientCard({
    required this.title,
    required this.kode,
    required this.jurusan,
    required this.semester,
    required this.dosen,
    required this.theme,
    required this.favorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final infoLine =
        <
          String
        >[
          if (kode !=
                  null &&
              kode!.isNotEmpty)
            'Kode: $kode',
          if (jurusan !=
                  null &&
              jurusan!.isNotEmpty)
            jurusan!,
          if (semester !=
                  null &&
              semester!.isNotEmpty)
            'Semester $semester',
        ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        22,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          22,
        ),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.gradient.first.withOpacity(
                  0.25,
                ),
                blurRadius: 22,
                offset: const Offset(
                  0,
                  14,
                ),
              ),
            ],
          ),
          child: Stack(
            children: [
              // soft shapes
              Positioned(
                right: -40,
                top: -40,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.14,
                  ),
                  size: 170,
                ),
              ),
              Positioned(
                right: -10,
                bottom: -55,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.10,
                  ),
                  size: 220,
                ),
              ),
              Positioned(
                left: 120,
                bottom: -60,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.08,
                  ),
                  size: 200,
                ),
              ),

              // star (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.24,
                      ),
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.20,
                        ),
                      ),
                    ),
                    child: Icon(
                      favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // teks (full width)
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
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      infoLine.isEmpty
                          ? '-'
                          : infoLine.join(
                              ' • ',
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(
                          0.90,
                        ),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: Colors.white.withOpacity(
                            0.92,
                          ),
                          size: 18,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            dosen,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                0.95,
                              ),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
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

  // masih disimpan untuk kompatibilitas struktur, tapi tidak dipakai lagi di card
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
