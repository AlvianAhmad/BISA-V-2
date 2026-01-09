// lib/presentation/pages/mahasiswa/mahasiswa_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'kelas/kelas_page.dart';
import 'akun/akun_page.dart';
import 'lexa/lexa_chat_page.dart';

class MahasiswaPage
    extends
        StatefulWidget {
  const MahasiswaPage({
    super.key,
  });

  @override
  State<
    MahasiswaPage
  >
  createState() => _MahasiswaPageState();
}

class _MahasiswaPageState
    extends
        State<
          MahasiswaPage
        > {
  int _tab = 0;

  @override
  Widget build(
    BuildContext context,
  ) {
    final pages =
        <
          Widget
        >[
          _HomeDashboard(
            onOpenKelas: () => _push(
              const KelasPage(),
            ),
            onOpenJadwal: () => _push(
              const KelasPage(),
            ),
            onOpenTugas: () => _push(
              const KelasPage(),
            ),
            onOpenNilai: () => _push(
              const _PlaceholderPage(
                title: 'Nilai',
              ),
            ),
          ),
          const KelasPage(), // Materi (sementara pilih kelas dulu)
          const KelasPage(), // Jadwal (sementara pilih kelas dulu)
          const LexaChatPage(), // Chat
          const AkunPage(), // Akun
        ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(
        0xFFF5F6FA,
      ),
      body: SafeArea(
        top: false,
        child: pages[_tab],
      ),
      bottomNavigationBar: _BottomNav(
        index: _tab,
        onChanged:
            (
              i,
            ) => setState(
              () => _tab = i,
            ),
      ),
    );
  }

  void _push(
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => page,
      ),
    );
  }
}

class _HomeDashboard
    extends
        StatelessWidget {
  final VoidCallback onOpenKelas;
  final VoidCallback onOpenJadwal;
  final VoidCallback onOpenTugas;
  final VoidCallback onOpenNilai;

  const _HomeDashboard({
    required this.onOpenKelas,
    required this.onOpenJadwal,
    required this.onOpenTugas,
    required this.onOpenNilai,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeaderWithQuickMenu(
            onKelas: onOpenKelas,
            onJadwal: onOpenJadwal,
            onTugas: onOpenTugas,
            onNilai: onOpenNilai,
          ),
        ),

        // ✅ HANYA CARD PROFIL (tanpa judul "Informasi Pribadi" / "Data mahasiswa")
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              20,
            ),
            child: const _MahasiswaInfoCardBlue(),
          ),
        ),
      ],
    );
  }
}

class _HeaderWithQuickMenu
    extends
        StatelessWidget {
  final VoidCallback onKelas;
  final VoidCallback onJadwal;
  final VoidCallback onTugas;
  final VoidCallback onNilai;

  const _HeaderWithQuickMenu({
    required this.onKelas,
    required this.onJadwal,
    required this.onTugas,
    required this.onNilai,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: _Header(),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
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
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFF5F6FA,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                        0x14000000,
                      ),
                      blurRadius: 18,
                      offset: Offset(
                        0,
                        -6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: _QuickMenuRow(
                onKelas: onKelas,
                onJadwal: onJadwal,
                onTugas: onTugas,
                onNilai: onNilai,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header
    extends
        StatelessWidget {
  const _Header();

  static const Color _primary = Color(
    0xFF0E2E72,
  );
  static const Color _primary2 = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = FirebaseAuth.instance.currentUser;

    final Stream<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >
    stream =
        user ==
            null
        ? const Stream.empty()
        : FirebaseFirestore.instance
              .collection(
                'users',
              )
              .doc(
                user.uid,
              )
              .snapshots();

    return StreamBuilder<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      stream: stream,
      builder:
          (
            context,
            snap,
          ) {
            final data =
                snap.data?.data() ??
                {};

            final nama =
                (data['nama'] ??
                        user?.displayName ??
                        'Mahasiswa')
                    .toString();
            final npm =
                (data['npm'] ??
                        data['nim'] ??
                        '')
                    .toString();
            final prodi =
                (data['prodi'] ??
                        data['programStudi'] ??
                        '')
                    .toString();

            final subtitleParts =
                <
                  String
                >[];
            if (npm
                .trim()
                .isNotEmpty)
              subtitleParts.add(
                'NPM: $npm',
              );
            if (prodi
                .trim()
                .isNotEmpty)
              subtitleParts.add(
                prodi,
              );

            return Container(
              height: 210,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primary2,
                    _primary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -80,
                    top: 80,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -120,
                    top: -40,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      56,
                      18,
                      16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $nama',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                subtitleParts.isEmpty
                                    ? 'Selamat datang di LMS'
                                    : subtitleParts.join(
                                        ' • ',
                                      ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _Avatar(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _Avatar
    extends
        StatelessWidget {
  const _Avatar();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          0.15,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.8,
          ),
          width: 2.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _QuickMenuRow
    extends
        StatelessWidget {
  final VoidCallback onKelas;
  final VoidCallback onJadwal;
  final VoidCallback onTugas;
  final VoidCallback onNilai;

  const _QuickMenuRow({
    required this.onKelas,
    required this.onJadwal,
    required this.onTugas,
    required this.onNilai,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickMenuCard(
            title: 'Kelas Saya',
            icon: Icons.menu_book_rounded,
            color: const Color(
              0xFFFB6B4A,
            ),
            onTap: onKelas,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Jadwal',
            icon: Icons.event_available_rounded,
            color: const Color(
              0xFF2D7FF9,
            ),
            onTap: onJadwal,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Tugas',
            icon: Icons.assignment_rounded,
            color: const Color(
              0xFFFF9F2E,
            ),
            onTap: onTugas,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Nilai',
            icon: Icons.school_rounded,
            color: const Color(
              0xFF2E9E67,
            ),
            onTap: onOpenNilaiGuard(
              context,
            ),
          ),
        ),
      ],
    );
  }

  // biar konsisten seperti yang lain (tanpa ubah struktur)
  VoidCallback onOpenNilaiGuard(
    BuildContext context,
  ) => onNilai;
}

class _QuickMenuCard
    extends
        StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickMenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              16,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(
                  0.25,
                ),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// ✅ CARD BIRU (Nama, NPM, Prodi) - tanpa teks "Profil Mahasiswa" & tanpa banner bawah
// =====================
class _MahasiswaInfoCardBlue
    extends
        StatelessWidget {
  const _MahasiswaInfoCardBlue();

  static const Color _a = Color(
    0xFF1B3C9E,
  );
  static const Color _b = Color(
    0xFF0E2E72,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = FirebaseAuth.instance.currentUser;

    if (user ==
        null) {
      return const _MiniStateCard(
        icon: Icons.lock_outline_rounded,
        title: 'Belum login',
        subtitle: 'Silakan login untuk melihat informasi.',
      );
    }

    return StreamBuilder<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      stream: FirebaseFirestore.instance
          .collection(
            'users',
          )
          .doc(
            user.uid,
          )
          .snapshots(),
      builder:
          (
            context,
            snap,
          ) {
            if (snap.connectionState ==
                ConnectionState.waiting) {
              return const _MiniLoadingCard();
            }
            if (snap.hasError) {
              return const _MiniStateCard(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat data',
                subtitle: 'Coba cek koneksi / Firestore rules.',
              );
            }

            final data =
                snap.data?.data() ??
                {};

            final nama =
                (data['nama'] ??
                        user.displayName ??
                        '-')
                    .toString();
            final npm =
                (data['npm'] ??
                        data['nim'] ??
                        '-')
                    .toString();
            final prodi =
                (data['prodi'] ??
                        data['programStudi'] ??
                        '-')
                    .toString();

            return ClipRRect(
              borderRadius: BorderRadius.circular(
                22,
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _a,
                      _b,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _a.withOpacity(
                        0.28,
                      ),
                      blurRadius: 26,
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
                      right: -40,
                      top: -50,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -70,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.08,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
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
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _BluePill(
                                    label: 'NPM',
                                    value: npm,
                                  ),
                                  _BluePill(
                                    label: 'Prodi',
                                    value: prodi,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}

class _BluePill
    extends
        StatelessWidget {
  final String label;
  final String value;

  const _BluePill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.14,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(
                0.85,
              ),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 190,
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLoadingCard
    extends
        StatelessWidget {
  const _MiniLoadingCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 92,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.05,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            'Memuat profil...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(
                0xFF6F7AA6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStateCard
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MiniStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
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
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.05,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _primary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              icon,
              color: _primary,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _muted,
                    fontSize: 12.5,
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

class _BottomNav
    extends
        StatelessWidget {
  final int index;
  final ValueChanged<
    int
  >
  onChanged;

  const _BottomNav({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1B3C9E,
            ),
            borderRadius: BorderRadius.circular(
              26,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x22000000,
                ),
                blurRadius: 24,
                offset: Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              26,
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: onChanged,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Colors.white,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                color: Colors.white70,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_rounded,
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu_book_rounded,
                  ),
                  label: 'Materi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: 'Jadwal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_bubble_rounded,
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_rounded,
                  ),
                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage
    extends
        StatelessWidget {
  final String title;
  const _PlaceholderPage({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      body: const Center(
        child: Text(
          'Halaman belum dibuat',
        ),
      ),
    );
  }
}
