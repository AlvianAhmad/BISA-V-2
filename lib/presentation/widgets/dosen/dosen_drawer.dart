import 'package:flutter/material.dart';

class DosenDrawer extends StatelessWidget {
  final VoidCallback onTapDashboard;
  final VoidCallback onTapLogout;

  const DosenDrawer({
    super.key,
    required this.onTapDashboard,
    required this.onTapLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ================= HEADER =================
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0E2E72)),
            accountName: const Text(
              'Dosen',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('dosen@bisa.ac.id'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.school_rounded, // ✅ ICON VALID
                color: Color(0xFF0E2E72),
                size: 28,
              ),
            ),
          ),

          // ================= MENU =================
          _drawerItem(
            context,
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              onTapDashboard();
            },
          ),

          const Spacer(),
          const Divider(height: 1),

          // ================= LOGOUT =================
          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              onTapLogout();
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
