import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/dosen/dosen_dashboard_viewmodel.dart';
import '../../widgets/dosen/dosen_drawer.dart';
import '../../widgets/dosen/dosen_sliver_appbar.dart';

// ===== DOSEN MODULE PAGES =====
import 'jadwal/jadwal_dosen_page.dart';
import 'kelas/kelas_dosen_page.dart';
import 'tugas/tugas_dosen_page.dart';
import 'materi/materi_dosen_page.dart';
import 'absensi/absensi_dosen_page.dart';
import 'lexa/lexa_chat_page.dart';

class DosenPage extends StatelessWidget {
  const DosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DosenDashboardViewModel()..init(),
      child: const _DosenPageView(),
    );
  }
}

class _DosenPageView extends StatelessWidget {
  const _DosenPageView();

  static const Color _primary = Color(0xFF0E2E72);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DosenDashboardViewModel>();
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width >= 900 ? 3 : 2;
    final ratio = width >= 1200 ? 1.35 : 1.25;

    return Scaffold(
      drawer: DosenDrawer(
        onTapDashboard: () => vm.snack(context, 'Dashboard'),
        onTapLogout: () => vm.logoutWithConfirm(
          context: context,
          routeBuilder: _fadeRoute,
          primaryColor: _primary,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ===== SLIVER APP BAR =====
          DosenSliverAppBar(
            onTapNotifications: () =>
                vm.snack(context, 'Notifikasi belum tersedia'),
            onTapSettings: () => vm.snack(context, 'Pengaturan belum tersedia'),
          ),

          // ===== MENU GRID =====
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: ratio,
              ),
              delegate: SliverChildListDelegate([
                _MenuTile(
                  icon: Icons.schedule_rounded,
                  title: 'Jadwal',
                  subtitle: 'Kelola jadwal',
                  onTap: () => _go(context, const JadwalPage()),
                ),
                _MenuTile(
                  icon: Icons.class_outlined,
                  title: 'Kelas',
                  subtitle: 'Data kelas',
                  onTap: () => _go(context, const KelasPage()),
                ),
                _MenuTile(
                  icon: Icons.assignment_outlined,
                  title: 'Tugas',
                  subtitle: 'Kelola tugas',
                  onTap: () => _go(context, const TugasPage()),
                ),
                _MenuTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Materi',
                  subtitle: 'Bahan ajar',
                  onTap: () => _go(context, const KelasPage()),
                ),

                _MenuTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Absensi',
                  subtitle: 'Kehadiran',
                  onTap: () => _go(context, const AbsensiPage()),
                ),
                _MenuTile(
                  icon: Icons.smart_toy_outlined,
                  title: 'LEXA',
                  subtitle: 'Asisten AI',
                  onTap: () => _go(context, const LexaChatPage()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static void _go(BuildContext context, Widget page) {
    Navigator.push(context, _fadeRoute(page));
  }
}

// ===== MENU TILE =====
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2E72).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0E2E72)),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== FADE ROUTE =====
PageRoute _fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
