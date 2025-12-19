import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/auth/login_page.dart';

class CustomSettingsDrawer
    extends
        StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const CustomSettingsDrawer({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(
                0xFF002F6C,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Pengaturan",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Kelola preferensi akun",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(
              LucideIcons.user,
            ),
            title: Text(
              "Akun",
              style: GoogleFonts.poppins(),
            ),
            onTap: () {
              Navigator.pop(
                context,
              );
            },
          ),

          ListTile(
            leading: const Icon(
              LucideIcons.shield,
            ),
            title: Text(
              "Privasi & Keamanan",
              style: GoogleFonts.poppins(),
            ),
            onTap: () {
              Navigator.pop(
                context,
              );
            },
          ),

          ListTile(
            leading: Icon(
              isDarkMode
                  ? LucideIcons.moon
                  : LucideIcons.sunMedium,
              color: Colors.indigo,
            ),
            title: Text(
              isDarkMode
                  ? "Mode Gelap"
                  : "Mode Terang",
              style: GoogleFonts.poppins(),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged:
                  (
                    _,
                  ) => onToggleTheme(),
            ),
            onTap: onToggleTheme,
          ),

          ListTile(
            leading: const Icon(
              LucideIcons.helpCircle,
            ),
            title: Text(
              "Bantuan",
              style: GoogleFonts.poppins(),
            ),
            onTap: () {
              Navigator.pop(
                context,
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              LucideIcons.logOut,
              color: Colors.red,
            ),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.red,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => const LoginPage(),
                ),
                (
                  _,
                ) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
