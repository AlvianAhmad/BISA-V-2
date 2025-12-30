// lib/presentation/pages/admin/admin_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:bisa/presentation/pages/admin/absensi/absensi_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_user_page.dart';
import 'package:bisa/presentation/pages/admin/jadwal/jadwal_admin_page.dart';
import 'package:bisa/presentation/pages/admin/kelas/kelas_admin_page.dart';
import 'package:bisa/presentation/pages/admin/tugas/tugas_admin_page.dart';

import '../../widgets/admin/admin_drawer.dart';
import 'package:bisa/presentation/viewmodels/admin/admin_dashboard_viewmodel.dart';
import 'lexa/lexa_chat_page.dart';

class AdminPage
    extends
        StatelessWidget {
  const AdminPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ChangeNotifierProvider<
      AdminDashboardViewModel
    >(
      create:
          (
            _,
          ) => AdminDashboardViewModel()..init(),
      child: const _AdminPageView(),
    );
  }
}

class _AdminPageView
    extends
        StatelessWidget {
  const _AdminPageView();

  // ====== THEME COLORS (Minimalis biru-putih) ======
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

  // Animasi transisi halaman: fade + sedikit slide
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
    // kamu bisa ubah rules ini kalau mau
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
          AdminDashboardViewModel
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

    // biar tinggi card grid tetap enak di desktop
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
      drawer: AdminDrawer(
        onTapDashboard: () => vm.snack(
          context,
          'Dashboard',
        ),
        onTapManajemenUser: () => vm.onTapNotImplemented(
          context,
          'Manajemen User',
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

        // penting biar ga berubah warna saat scroll (Material 3)
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        centerTitle: false,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => vm.onTapNotifications(
              context,
            ),
            icon: Icon(
              Icons.notifications_none_outlined,
              color: _primary,
            ),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => vm.onTapSettings(
              context,
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

                      child: _HeroBanner(
                        primary: _primary,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        10,
                      ),
                      child: _SectionTitle(
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
                            icon: Icons.school_outlined,
                            title: 'Mahasiswa',
                            value: vm.mahasiswaCount.toString(),
                            subtitle: 'Total akun',
                          ),
                          _StatCardModern(
                            icon: Icons.badge_outlined,
                            title: 'Dosen',
                            value: vm.dosenCount.toString(),
                            subtitle: 'Total akun',
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        10,
                      ),
                      child: _SectionTitle(
                        title: 'Menu Utama',
                        subtitle: 'Akses cepat modul admin',
                        text: _text,
                        muted: _muted,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: _PrimaryActionCard(
                        title: 'Buat Akun Mahasiswa / Dosen',
                        subtitle: 'Tambah user baru dengan role yang sesuai',
                        icon: Icons.person_add_alt_outlined,
                        primary: _primary,
                        onTap: () => Navigator.push(
                          context,
                          _fadeRoute(
                            const CreateUserPage(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        10,
                      ),
                      child: _SectionTitle(
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
                          _MenuTile(
                            title: 'Jadwal',
                            subtitle: 'Kelola jadwal',
                            icon: Icons.calendar_month_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const JadwalPage(),
                              ),
                            ),
                          ),
                          _MenuTile(
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
                          _MenuTile(
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
                          _MenuTile(
                            title: 'Materi',
                            subtitle: 'Bahan ajar',
                            icon: Icons.menu_book_outlined,
                            primary: _primary,
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(
                                const KelasPage(),
                              ),
                            ),
                          ),
                          _MenuTile(
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

                          _MenuTile(
                            title: 'LEXA',
                            subtitle: 'Chat Bot',
                            icon: Icons.smart_toy_outlined,
                            primary: _primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (
                                        _,
                                      ) => const LexaChatPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),

      floatingActionButton: _FabModern(
        primary: _primary,
        onTap: () => Navigator.push(
          context,
          _fadeRoute(
            const CreateUserPage(),
          ),
        ),
      ),
    );
  }
}

// =============================
// UI COMPONENTS (VIEW ONLY)
// =============================
class _HeroBanner
    extends
        StatelessWidget {
  final Color primary;
  const _HeroBanner({
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                  'Kelola aktivitas kampus\nlebih cepat dan rapi.',
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
                  'Gunakan menu di bawah untuk mengatur jadwal,\nabsensi, tugas, dan materi.',
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
              Icons.dashboard_outlined,
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
          // icon box
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

          // text area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title
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

                // value + chip
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

                // divider tipis biar rapih
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

                // hint kecil (optional)
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

class _PrimaryActionCard
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _PrimaryActionCard({
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
          horizontal: 14,
          vertical: 6,
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 2,
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

class _MenuTile
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _MenuTile({
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

class _FabModern
    extends
        StatelessWidget {
  final Color primary;
  final VoidCallback onTap;
  const _FabModern({
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
        height: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(
            16,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(
                0.28,
              ),
              blurRadius: 18,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_outlined,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Buat Akun',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
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
