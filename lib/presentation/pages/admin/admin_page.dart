import 'package:bisa/presentation/pages/admin/absensi/absensi_admin_page.dart';
import 'package:flutter/material.dart';
import 'create_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_page.dart';
// import '../../pages/auth/login_page.dart'; // sesuaikan path

import 'package:bisa/presentation/pages/admin/jadwal/jadwal_admin_page.dart';
import 'package:bisa/presentation/pages/admin/kelas/kelas_admin_page.dart';
import 'package:bisa/presentation/pages/admin/tugas/tugas_admin_page.dart';
import 'package:bisa/presentation/pages/admin/materi/materi_admin_page.dart';
import '../../widgets/admin/admin_drawer.dart';
import '../../widgets/admin/admin_sliver_appbar.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Yakin logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // ====== PROSES LOGOUT ======
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    // 🔥 INI YANG PALING PENTING
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // HAPUS SEMUA HALAMAN SEBELUMNYA
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),

      // DRAWER (terpisah)
      // NOTE: pastikan AdminDrawer kamu SUDAH TIDAK punya onTapLaporan
      drawer: AdminDrawer(
        onTapDashboard: () => _snack(context, 'Dashboard'),
        onTapManajemenUser: () =>
            _snack(context, 'Manajemen User belum dihubungkan'),
        onTapLogout: () {
          _confirmLogout(context); // ✅ PANGGIL FUNGSI INI
        },
      ),

      body: CustomScrollView(
        slivers: [
          // APPBAR (terpisah)
          AdminSliverAppBar(
            onTapNotifications: () =>
                _snack(context, 'Notifikasi belum tersedia'),
            onTapSettings: () => _snack(context, 'Pengaturan belum tersedia'),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.school_rounded,
                          title: 'Mahasiswa',
                          value: '—',
                          subtitle: 'Total akun',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.badge_rounded,
                          title: 'Dosen',
                          value: '—',
                          subtitle: 'Total akun',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Menu Utama',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A2552),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Main action card
                  _ActionCard(
                    title: 'Buat Akun Mahasiswa / Dosen',
                    subtitle: 'Tambah user baru dengan role yang sesuai',
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateUserPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // GRID MENU (8 menu)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MiniMenuCard(
                        title: 'Jadwal',
                        icon: Icons.calendar_month_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JadwalPage(),
                            ),
                          );
                        },
                      ),

                      _MiniMenuCard(
                        title: 'Absensi',
                        icon: Icons.how_to_reg_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AbsensiPage(),
                            ),
                          );
                        },
                      ),
                      _MiniMenuCard(
                        title: 'Tugas',
                        icon: Icons.assignment_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TugasPage(),
                            ),
                          );
                        },
                      ),
                      _MiniMenuCard(
                        title: 'Materi',
                        icon: Icons.menu_book_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KelasPage(),
                            ),
                          );
                        },
                      ),

                      _MiniMenuCard(
                        title: 'Kelas',
                        icon: Icons.calendar_month_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KelasPage(),
                            ),
                          );
                        },
                      ),
                      _MiniMenuCard(
                        title: 'Info',
                        icon: Icons.info_outline_rounded,
                        onTap: () => _snack(context, 'Menu Info'),
                      ),
                      _MiniMenuCard(
                        title: 'Diskusi',
                        icon: Icons.forum_rounded,
                        onTap: () => _snack(context, 'Menu Diskusi'),
                      ),
                      _MiniMenuCard(
                        title: 'LEXA',
                        icon: Icons.smart_toy_rounded,
                        onTap: () => _snack(context, 'LEXA (Chat Bot)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0E2E72),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Buat Akun',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateUserPage()),
          );
        },
      ),
    );
  }
}

// ====== PRIVATE WIDGETS DI FILE INI SAJA ======

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0E2E72).withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0E2E72)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF58608B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF1A2552),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B92B2),
                    fontWeight: FontWeight.w600,
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2E72).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF0E2E72), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2552),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF7A83AA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7A83AA)),
          ],
        ),
      ),
    );
  }
}

class _MiniMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MiniMenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0E2E72).withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0E2E72)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2552),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
