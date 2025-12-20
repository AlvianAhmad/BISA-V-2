import 'package:flutter/material.dart';

class AdminSliverAppBar
    extends
        StatelessWidget {
  final VoidCallback onTapNotifications;
  final VoidCallback onTapSettings;

  const AdminSliverAppBar({
    super.key,
    required this.onTapNotifications,
    required this.onTapSettings,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(
        0xFF0E2E72,
      ),
      centerTitle: true,

      leading: Builder(
        builder:
            (
              context,
            ) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => Scaffold.of(
                context,
              ).openDrawer(),
            ),
      ),

      title: const Text(
        'Admin Panel',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
          onPressed: onTapNotifications,
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
          ),
          onPressed: onTapSettings,
        ),
        const SizedBox(
          width: 8,
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(
                      0xFF0E2E72,
                    ),
                    Color(
                      0xFF1E54B7,
                    ),
                    Color(
                      0xFF3A7BD5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.12,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.10,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  60,
                  16,
                  16,
                ),
                child: Row(
                  children: [
                    _HeaderIcon(),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: _HeaderText(),
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

class _HeaderIcon
    extends
        StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.18,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _HeaderText
    extends
        StatelessWidget {
  const _HeaderText();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Kelola Sistem',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          'Buat akun, pantau data, dan kelola pengguna',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
