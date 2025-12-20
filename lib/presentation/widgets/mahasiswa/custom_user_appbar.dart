import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomUserAppBar
    extends
        StatelessWidget
    implements
        PreferredSizeWidget {
  final String userName;
  final String subtitle;
  final String? avatarAssetPath;
  final VoidCallback? onSettingsTap;

  const CustomUserAppBar({
    super.key,
    required this.userName,
    this.subtitle = 'Program / Kelas',
    this.avatarAssetPath,
    this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(
    60,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: false,
      automaticallyImplyLeading: false, // kita buat sendiri tombol drawer

      titleSpacing: 0,
      title: Row(
        children: [
          // ✅ tombol drawer yang pasti jalan
          Builder(
            builder:
                (
                  context,
                ) => IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color(
                      0xFF002F6C,
                    ),
                  ),
                  onPressed: () => Scaffold.of(
                    context,
                  ).openDrawer(),
                ),
          ),

          const SizedBox(
            width: 4,
          ),

          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(
              0xFFE9F0FF,
            ),
            backgroundImage:
                (avatarAssetPath !=
                    null)
                ? AssetImage(
                    avatarAssetPath!,
                  )
                : null,
            child:
                (avatarAssetPath ==
                    null)
                ? const Icon(
                    Icons.person,
                    color: Color(
                      0xFF002F6C,
                    ),
                  )
                : null,
          ),

          const SizedBox(
            width: 10,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(
                    0xFF0C3C78,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed:
              onSettingsTap ??
              () {},
          icon: const Icon(
            LucideIcons.settings,
            color: Color(
              0xFF002F6C,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}
