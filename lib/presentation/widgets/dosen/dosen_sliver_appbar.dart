import 'package:flutter/material.dart';

class DosenSliverAppBar extends StatelessWidget {
  final VoidCallback onTapNotifications;
  final VoidCallback onTapSettings;

  const DosenSliverAppBar({
    super.key,
    required this.onTapNotifications,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0E2E72),

      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),

      title: const Text(
        'Dashboard Dosen',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: onTapSettings,
        ),
        const SizedBox(width: 8),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ===== GRADIENT =====
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E2E72),
                    Color(0xFF1E54B7),
                    Color(0xFF3A7BD5),
                  ],
                ),
              ),
            ),

            // ===== DECOR CIRCLE =====
            Positioned(
              top: -30,
              right: -30,
              child: _BlurCircle(size: 120, opacity: 0.12),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: _BlurCircle(size: 160, opacity: 0.10),
            ),

            // ===== HEADER CONTENT =====
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Row(
                  children: [
                    _HeaderIcon(),
                    SizedBox(width: 12),
                    Expanded(child: _HeaderText()),
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

/* ================= WIDGET KECIL ================= */

class _BlurCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _BlurCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.school_rounded, // ✅ ICON VALID
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Selamat Datang, Dosen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Kelola kelas, tugas, materi, dan absensi',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
