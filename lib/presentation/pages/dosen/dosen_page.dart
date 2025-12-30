// lib/presentation/pages/dosen/dosen_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/dosen/dosen_dashboard_viewmodel.dart';
import '../../widgets/dosen/dosen_drawer.dart';

// ===== DOSEN MODULE PAGES =====
import 'jadwal/jadwal_dosen_page.dart';
import 'kelas/kelas_dosen_page.dart';
import 'tugas/tugas_dosen_page.dart';
import 'absensi/absensi_dosen_page.dart';
import 'lexa/lexa_chat_page.dart';

// (Opsional) kalau kamu punya materi dosen, ganti route Materi di bawah
// import 'materi/materi_dosen_page.dart';

class DosenPage
    extends
        StatelessWidget {
  const DosenPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ChangeNotifierProvider<
      DosenDashboardViewModel
    >(
      create:
          (
            _,
          ) => DosenDashboardViewModel()..init(),
      child: const _DosenPageView(),
    );
  }
}

class _DosenPageView
    extends
        StatelessWidget {
  const _DosenPageView();

  // ====== THEME (samakan dengan Admin) ======
  static const Color _bg = Color(
    0xFFF4F7FF,
  );
  static const Color _primary = Color(
    0xFF0E2E72,
  );
  static const Color _text = Color(
    0xFF1A2552,
  );
  static const Color _muted = Color(
    0xFF6F7AA6,
  );

  // Animasi transisi halaman: fade + sedikit slide (samain admin)
  static PageRoute _fadeRoute(
    Widget page,
  ) {
    return PageRouteBuilder(
      transitionDuration: const Duration(
        milliseconds: 260,
      ),
      reverseTransitionDuration: const Duration(
        milliseconds: 220,
      ),
      pageBuilder:
          (
            _,
            __,
            ___,
          ) => page,
      transitionsBuilder:
          (
            _,
            animation,
            __,
            child,
          ) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final offsetAnim =
                Tween<
                      Offset
                    >(
                      begin: const Offset(
                        0.02,
                        0.02,
                      ),
                      end: Offset.zero,
                    )
                    .animate(
                      curved,
                    );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: offsetAnim,
                child: child,
              ),
            );
          },
    );
  }

  int _responsiveCrossAxisCount(
    double width,
  ) {
    if (width >=
        1200)
      return 4;
    if (width >=
        900)
      return 3;
    return 2;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .watch<
          DosenDashboardViewModel
        >();
    final width = MediaQuery.of(
      context,
    ).size.width;

    final modulCount = _responsiveCrossAxisCount(
      width,
    );
    final ringkasanCount =
        width >=
            900
        ? 3
        : 2;

    // rasio grid biar enak (samain admin)
    final modulRatio =
        width >=
            1200
        ? 3.6
        : (width >=
                  900
              ? 3.2
              : 2.8);
    final ringkasanRatio =
        width >=
            1200
        ? 2.4
        : 1.75;

    return Scaffold(
      backgroundColor: _bg,

      drawer: DosenDrawer(
        onTapDashboard: () => vm.snack(
          context,
          'Dashboard',
        ),
        onTapLogout: () => vm.logoutWithConfirm(
          context: context,
          routeBuilder: _fadeRoute,
          primaryColor: _primary,
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Dashboard Dosen',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => vm.snack(
              context,
              'Notifikasi belum tersedia',
            ),
            icon: Icon(
              Icons.notifications_none_outlined,
              color: _primary,
            ),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => vm.snack(
              context,
              'Pengaturan belum tersedia',
            ),
            icon: Icon(
              Icons.settings_outlined,
              color: _primary,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),

      body: SafeArea(
        top: true,
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        0,
                      ),
                      child: const _HeroBannerDosen(
                        primary: _primary,
                      ),
                    ),
                  ),

                  // ===== RINGKASAN =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        10,
                      ),
                      child: const _SectionTitle(
                        title: 'Ringkasan',
                        subtitle: 'Pantau aktivitas dan akses cepat fitur utama',
                        text: _text,
                        muted: _muted,
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ringkasanCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: ringkasanRatio,
                      ),
                      delegate: SliverChildListDelegate(
                        [
                          _StatCardModern(
                            icon: Icons.class_outlined,
                            title: 'Kelas',
                            value: vm.kelasCount.toString(),
                            subtitle: 'Total kelas',
                          ),
                          _StatCardModern(
                            icon: Icons.assignment_outlined,
                            title: 'Tugas',
                            value: vm.tugasCount.toString(),
                            subtitle: 'Total tugas',
                          ),
                          _StatCardModern(
                            icon: Icons.fact_check_outlined,
                            title: 'Absensi',
                            value: vm.absensiCount.toString(),
                            subtitle: 'Rekap hari ini',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== MODUL =====
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        10,
                      ),
                      child: const _SectionTitle(
                        title: 'Modul',
                        subtitle: 'Pilih modul untuk mengelola data',
                        text: _text,
                        muted: _muted,
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      90,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: modulCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: modulRatio,
                      ),
                      delegate: SliverChildListDelegate(
                        [
                          _MenuTileModern(
                            title: 'Jadwal',
                            subtitle: 'Kelola jadwal',
                            icon: Icons.calendar_month_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const JadwalDosenPage(),
                              ),
                            ),
                          ),
                          _MenuTileModern(
                            title: 'Absensi',
                            subtitle: 'Kehadiran',
                            icon: Icons.how_to_reg_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const AbsensiPage(),
                              ),
                            ),
                          ),
                          _MenuTileModern(
                            title: 'Tugas',
                            subtitle: 'Penugasan',
                            icon: Icons.assignment_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const TugasPage(),
                              ),
                            ),
                          ),
                          _MenuTileModern(
                            title: 'Materi',
                            subtitle: 'Bahan ajar',
                            icon: Icons.menu_book_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const KelasPage(),
                              ),
                              // TODO: ganti ke MateriDosenPage kalau sudah ada
                            ),
                          ),
                          _MenuTileModern(
                            title: 'Kelas',
                            subtitle: 'Manajemen kelas',
                            icon: Icons.class_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const KelasPage(),
                              ),
                            ),
                          ),
                          _MenuTileModern(
                            title: 'LEXA',
                            subtitle: 'Chat Bot',
                            icon: Icons.smart_toy_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const LexaChatPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =============================
// UI COMPONENTS (SAMA VIBE ADMIN)
// =============================

class _HeroBannerDosen
    extends
        StatelessWidget {
  final Color primary;
  const _HeroBannerDosen({
    required this.primary,
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
        borderRadius: BorderRadius.circular(
          22,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withOpacity(
              0.88,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(
              0.20,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Kelola kelas & tugas\nlebih cepat dan rapi.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Gunakan menu di bawah untuk jadwal,\nabsensi, tugas, dan materi.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.16,
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
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final Color text;
  final Color muted;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
      ],
    );
  }
}

class _StatCardModern
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCardModern({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.05,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius: 14,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  const Color(
                    0xFF0E2E72,
                  ).withOpacity(
                    0.10,
                  ),
              borderRadius: BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color:
                    const Color(
                      0xFF0E2E72,
                    ).withOpacity(
                      0.10,
                    ),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(
                0xFF0E2E72,
              ),
              size: 24,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(
                      0xFF58608B,
                    ),
                    height: 1.1,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(
                            0xFF1A2552,
                          ),
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(
                              0xFF0E2E72,
                            ).withOpacity(
                              0.08,
                            ),
                        borderRadius: BorderRadius.circular(
                          999,
                        ),
                        border: Border.all(
                          color:
                              const Color(
                                0xFF0E2E72,
                              ).withOpacity(
                                0.10,
                              ),
                        ),
                      ),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(
                            0xFF0E2E72,
                          ),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.black.withOpacity(
                    0.05,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'Terupdate otomatis',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF8B92B2,
                    ),
                    height: 1.0,
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

class _MenuTileModern
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _MenuTileModern({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: Colors.black.withOpacity(
              0.05,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ),
              blurRadius: 14,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withOpacity(
                  0.10,
                ),
                borderRadius: BorderRadius.circular(
                  14,
                ),
              ),
              child: Icon(
                icon,
                color: primary,
                size: 22,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(
                        0xFF1A2552,
                      ),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF7A83AA,
                      ),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(
                0xFFB0B7D5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapScale
    extends
        StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapScale({
    required this.child,
    required this.onTap,
  });

  @override
  State<
    _TapScale
  >
  createState() => _TapScaleState();
}

class _TapScaleState
    extends
        State<
          _TapScale
        > {
  bool _down = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown:
          (
            _,
          ) => setState(
            () => _down = true,
          ),
      onTapCancel: () => setState(
        () => _down = false,
      ),
      onTapUp:
          (
            _,
          ) => setState(
            () => _down = false,
          ),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down
            ? 0.98
            : 1.0,
        duration: const Duration(
          milliseconds: 110,
        ),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
