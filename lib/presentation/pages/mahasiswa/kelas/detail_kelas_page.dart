// lib/presentation/pages/mahasiswa/kelas/detail_kelas_page.dart
// ignore_for_file: unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import '../materi/materi_page.dart';
import '../tugas/tugas_page.dart';
import '../absensi/absensi_page.dart';
import '../jadwal/jadwal_page.dart';

// ✅ GLOBAL THEME
const Color
kBg = Color(
  0xFFF5F6FA,
);
const Color
kTextDark = Color(
  0xFF1A2552,
);
const Color
kMuted = Color(
  0xFF6F7AA6,
);

class DetailKelasPage
    extends
        StatefulWidget {
  final String kelasId;

  const DetailKelasPage({
    super.key,
    required this.kelasId,
  });

  @override
  State<
    DetailKelasPage
  >
  createState() => _DetailKelasPageState();
}

class _DetailKelasPageState
    extends
        State<
          DetailKelasPage
        > {
  static const String _fallbackBannerUrl = 'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?auto=format&fit=crop&w=1600&q=60';

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .watch<
          MahasiswaViewModel
        >();

    return Scaffold(
      backgroundColor: kBg,
      body:
          StreamBuilder<
            DocumentSnapshot<
              Map<
                String,
                dynamic
              >
            >
          >(
            stream: vm.detailKelas(
              widget.kelasId,
            ),
            builder:
                (
                  context,
                  snap,
                ) {
                  if (snap.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snap.error}',
                      ),
                    );
                  }
                  if (!snap.hasData ||
                      !snap.data!.exists) {
                    return const Center(
                      child: Text(
                        'Kelas tidak ditemukan',
                      ),
                    );
                  }

                  final data =
                      snap.data!.data() ??
                      {};
                  final kelasNama =
                      (data['nama'] ??
                              '')
                          .toString();
                  if (kelasNama.isEmpty) {
                    return const Center(
                      child: Text(
                        'Field "nama" kelas kosong',
                      ),
                    );
                  }

                  final jurusan =
                      (data['jurusan'] ??
                              'Teknik Informatika')
                          .toString();
                  final semester =
                      (data['semester'] ??
                              '4')
                          .toString();
                  final kode =
                      (data['kode'] ??
                              'PW1234')
                          .toString();
                  final dosen =
                      (data['dosen'] ??
                              'Dr. Andi Saputra')
                          .toString();
                  final bannerUrl =
                      (data['bannerUrl'] ??
                              _fallbackBannerUrl)
                          .toString();

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _HeaderWithSheet(
                          bannerUrl: bannerUrl,
                          title: kelasNama,
                          jurusan: jurusan,
                          semester: semester,
                          kode: kode,
                          dosen: dosen,
                          onBack: () => Navigator.pop(
                            context,
                          ),

                          // ✅ ACTION HAPUS (titik tiga)
                          onDelete: () async {
                            final ok = await _confirmDeleteKelas(
                              context,
                              kelasNama,
                            );
                            if (ok !=
                                true)
                              return;

                            try {
                              await vm.hapusKelasDariDaftarById(
                                widget.kelasId,
                              );

                              if (!mounted) return;

                              // ✅ JANGAN toast di halaman ini (karena habis pop context mati)
                              Navigator.pop(
                                context,
                                {
                                  'deleted': true,
                                  'message': 'Kelas berhasil dihapus',
                                },
                              );
                            } catch (
                              e
                            ) {
                              if (!mounted) return;

                              // kalau gagal, toast boleh tetap di halaman ini karena tidak pop
                              _showTopToast(
                                context,
                                message: 'Gagal menghapus kelas',
                                bgColor: Colors.red,
                                icon: Icons.error_rounded,
                              );
                            }
                          },
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Container(
                          color: kBg,
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            6,
                            16,
                            18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menu Kelas',
                                style: TextStyle(
                                  color: kTextDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Column(
                                children: [
                                  _MenuRowCard(
                                    title: 'Materi',
                                    subtitle: 'Modul & bahan ajar',
                                    icon: Icons.menu_book_rounded,
                                    gradient: const [
                                      Color(
                                        0xFF2D7FF9,
                                      ),
                                      Color(
                                        0xFF0E2E72,
                                      ),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                _,
                                              ) => MateriPage(
                                                kelasId: widget.kelasId,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  _MenuRowCard(
                                    title: 'Tugas',
                                    subtitle: 'Kumpulkan & lihat deadline',
                                    icon: Icons.assignment_rounded,
                                    gradient: const [
                                      Color(
                                        0xFFFFA34D,
                                      ),
                                      Color(
                                        0xFFF26B3A,
                                      ),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                _,
                                              ) => TugasPage(
                                                kelasNama: kelasNama,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  _MenuRowCard(
                                    title: 'Absensi',
                                    subtitle: 'Presensi per pertemuan',
                                    icon: Icons.fact_check_rounded,
                                    gradient: const [
                                      Color(
                                        0xFF2E9E67,
                                      ),
                                      Color(
                                        0xFF167A52,
                                      ),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                _,
                                              ) => AbsensiPage(
                                                kelasNama: kelasNama,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  _MenuRowCard(
                                    title: 'Jadwal',
                                    subtitle: 'Jam & ruang perkuliahan',
                                    icon: Icons.event_available_rounded,
                                    gradient: const [
                                      Color(
                                        0xFF6A5CFF,
                                      ),
                                      Color(
                                        0xFF1B3C9E,
                                      ),
                                    ],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                _,
                                              ) => JadwalPage(
                                                kelasNama: kelasNama,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
          ),
    );
  }

  // ===================== POPUP HAPUS (vibe sama kayak JadwalPage) =====================

  static Future<
    bool?
  >
  _confirmDeleteKelas(
    BuildContext context,
    String namaKelas,
  ) {
    return showGeneralDialog<
      bool
    >(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(
        0.45,
      ),
      transitionDuration: const Duration(
        milliseconds: 220,
      ),
      pageBuilder:
          (
            context,
            anim1,
            anim2,
          ) => const SizedBox.shrink(),
      transitionBuilder:
          (
            context,
            anim,
            _,
            __,
          ) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SafeArea(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                      false,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX:
                            10 *
                            curved.value,
                        sigmaY:
                            10 *
                            curved.value,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Center(
                    child: FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale:
                            Tween<
                                  double
                                >(
                                  begin: 0.95,
                                  end: 1.0,
                                )
                                .animate(
                                  curved,
                                ),
                        child: SlideTransition(
                          position:
                              Tween<
                                    Offset
                                  >(
                                    begin: const Offset(
                                      0,
                                      0.03,
                                    ),
                                    end: Offset.zero,
                                  )
                                  .animate(
                                    curved,
                                  ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          0.22,
                                        ),
                                        blurRadius: 34,
                                        offset: const Offset(
                                          0,
                                          18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(
                                            0.08,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.14,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  14,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            const Expanded(
                                              child: Text(
                                                'Hapus Kelas?',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: kTextDark,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(
                                                999,
                                              ),
                                              onTap: () => Navigator.pop(
                                                context,
                                                false,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(
                                                  6,
                                                ),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  color: kMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          14,
                                          16,
                                          2,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kamu yakin ingin menghapus kelas ini dari daftar kelas kamu?',
                                              style: TextStyle(
                                                color: kMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFF7F8FD,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  14,
                                                ),
                                                border: Border.all(
                                                  color: Colors.black.withOpacity(
                                                    0.06,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.class_rounded,
                                                    size: 18,
                                                    color: kMuted,
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      namaKelas,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: kTextDark,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            const Text(
                                              'Tindakan ini tidak dapat dibatalkan.',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 14,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: kTextDark,
                                                  side: BorderSide(
                                                    color: Colors.black.withOpacity(
                                                      0.12,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  // ===================== TOAST ATAS (vibe sama JadwalPage) =====================

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

class _HeaderWithSheet
    extends
        StatelessWidget {
  final String bannerUrl;
  final String title;
  final String jurusan;
  final String semester;
  final String kode;
  final String dosen;
  final VoidCallback onBack;

  // ✅ INI BUAT HAPUS DARI TITIK TIGA
  final VoidCallback onDelete;

  const _HeaderWithSheet({
    required this.bannerUrl,
    required this.title,
    required this.jurusan,
    required this.semester,
    required this.kode,
    required this.dosen,
    required this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        _,
                        __,
                        ___,
                      ) => Container(
                        color: const Color(
                          0xFF0E2E72,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(
                          0.20,
                        ),
                        Colors.black.withOpacity(
                          0.65,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 8,
            right: 8,
            top:
                MediaQuery.of(
                  context,
                ).padding.top +
                8,
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                  ),
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 2,
                ),
                const Expanded(
                  child: Text(
                    'Detail Kelas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),

                // ✅ TITIK TIGA DI POJOK KANAN
                PopupMenuButton<
                  String
                >(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                  color: Colors.white,
                  onSelected:
                      (
                        value,
                      ) {
                        if (value ==
                            'hapus')
                          onDelete();
                      },
                  itemBuilder:
                      (
                        _,
                      ) => const [
                        PopupMenuItem(
                          value: 'hapus',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Hapus dari daftar',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 66,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.15,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  jurusan,
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                      0.92,
                    ),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  'Semester $semester',
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                      0.86,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _GlassChip(
                        icon: Icons.confirmation_number_rounded,
                        text: 'KODE $kode',
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: _GlassChip(
                        icon: Icons.person_rounded,
                        text: dosen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: -8,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                  28,
                ),
                topRight: Radius.circular(
                  28,
                ),
              ),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: kBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.06,
                      ),
                      blurRadius: 22,
                      offset: const Offset(
                        0,
                        -10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip
    extends
        StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({
    required this.icon,
    required this.text,
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
          height: 46,
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
                0.22,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard
    extends
        StatelessWidget {
  final String title;
  final IconData icon;
  final List<
    Color
  >
  gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        22,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          22,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              22,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(
                  0.22,
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
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      0.12,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -28,
                bottom: -32,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      0.08,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.18,
                        ),
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            0.20,
                          ),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
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

class _MenuRowCard
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<
    Color
  >
  gradient;
  final VoidCallback onTap;

  const _MenuRowCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        20,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          20,
        ),
        child: Ink(
          height: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              20,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(
                  0.18,
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
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      0.10,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.18,
                        ),
                        borderRadius: BorderRadius.circular(
                          18,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            0.20,
                          ),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                0.85,
                              ),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26,
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
