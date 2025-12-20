import 'package:flutter/material.dart';

class AdminDrawer
    extends
        StatelessWidget {
  final VoidCallback onTapDashboard;
  final VoidCallback onTapManajemenUser;
  final VoidCallback onTapLogout;

  const AdminDrawer({
    super.key,
    required this.onTapDashboard,
    required this.onTapManajemenUser,
    required this.onTapLogout,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(
                0xFF0E2E72,
              ),
            ),
            accountName: const Text(
              'Admin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text(
              'admin@bisa.ac.id',
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                color: Color(
                  0xFF0E2E72,
                ),
                size: 28,
              ),
            ),
          ),

          _drawerItem(
            context,
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            onTap: () {
              Navigator.pop(
                context,
              );
              onTapDashboard();
            },
          ),

          _drawerItem(
            context,
            icon: Icons.people_alt_rounded,
            title: 'Manajemen User',
            onTap: () {
              Navigator.pop(
                context,
              );
              onTapManajemenUser();
            },
          ),

          const Spacer(),
          const Divider(
            height: 1,
          ),

          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(
                context,
              );
              onTapLogout(); // ✅ hanya callback
            },
          ),

          const SizedBox(
            height: 8,
          ),
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
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
      ),
      onTap: onTap,
    );
  }
}
