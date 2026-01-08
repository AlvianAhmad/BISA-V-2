// lib/presentation/pages/mahasiswa/mahasiswa_page.dart
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'kelas/kelas_page.dart';
import 'materi/materi_page.dart';
import 'tugas/tugas_page.dart';
// import 'absensi/absensi_page.dart';
import 'akun/akun_page.dart';

import 'jadwal/jadwal_page.dart';
import 'lexa/lexa_chat_page.dart';

class MahasiswaPage
    extends
        StatefulWidget {
  const MahasiswaPage({
    super.key,
  });

  @override
  State<
    MahasiswaPage
  >
  createState() => _MahasiswaPageState();
}

class _MahasiswaPageState
    extends
        State<
          MahasiswaPage
        > {
  // ⚠️ sementara hardcode, nanti ambil dari kelas yang di-join
  static const String kelasId = 'kelas_1';

  int _tab = 0;

  @override
  Widget build(
    BuildContext context,
  ) {
    final pages =
        <
          Widget
        >[
          _HomeDashboard(
            kelasId: kelasId,
            onOpenKelas: () => _push(
              const KelasPage(),
            ),
            onOpenJadwal: () => _push(
              const KelasPage(),
            ),
            onOpenTugas: () => _push(
              const KelasPage(),
            ),
            onOpenNilai: () => _push(
              const _PlaceholderPage(
                title: 'Nilai',
              ),
            ),
          ),

          const KelasPage(), // index 1 => Materi (pilih kelas dulu)
          const KelasPage(), // index 2 => Jadwal (pilih kelas dulu)
          const LexaChatPage(), // index 3 => Chat
          const AkunPage(), // index 4 => Akun (buat file baru)
        ];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(
        0xFFF5F6FA,
      ),
      body: SafeArea(
        top: false,
        child: pages[_tab],
      ),
      bottomNavigationBar: _BottomNav(
        index: _tab,
        onChanged:
            (
              i,
            ) => setState(
              () => _tab = i,
            ),
      ),
    );
  }

  void _push(
    Widget page,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (
              _,
            ) => page,
      ),
    );
  }
}

class _HomeDashboard
    extends
        StatelessWidget {
  final String kelasId;
  final VoidCallback onOpenKelas;
  final VoidCallback onOpenJadwal;
  final VoidCallback onOpenTugas;
  final VoidCallback onOpenNilai;

  const _HomeDashboard({
    required this.kelasId,
    required this.onOpenKelas,
    required this.onOpenJadwal,
    required this.onOpenTugas,
    required this.onOpenNilai,
  });

  static const Color _primary = Color(
    0xFF0E2E72,
  );
  static const Color _primary2 = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeaderWithQuickMenu(
            onKelas: onOpenKelas,
            onJadwal: onOpenJadwal,
            onTugas: onOpenTugas,
            onNilai: onOpenNilai,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              0,
            ),
            child: _SectionTitle(
              title: 'Jadwal Hari Ini',
              trailing: _PillButton(
                label: 'Lihat',
                onTap: onOpenJadwal,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              0,
            ),
            child: _TodayScheduleCard(
              gradientA: _primary2,
              gradientB: _primary,
              onOpenJadwal: onOpenJadwal,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              0,
            ),
            child: _SectionTitle(
              title: 'Aktivitas Terbaru',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              0,
            ),
            child: Column(
              children: const [
                _ActivityTile(
                  icon: Icons.assignment_turned_in_rounded,
                  iconBg: Color(
                    0xFFFFE1D6,
                  ),
                  iconColor: Color(
                    0xFFFB6B4A,
                  ),
                  title: 'Tugas: “Essai tentang AI”',
                  subtitle: 'Dikumpulkan 2 jam yang lalu',
                ),
                SizedBox(
                  height: 10,
                ),
                _ActivityTile(
                  icon: Icons.quiz_rounded,
                  iconBg: Color(
                    0xFFDFF6EA,
                  ),
                  iconColor: Color(
                    0xFF2E9E67,
                  ),
                  title: 'Kuis: “Quiz Bab 3”',
                  subtitle: 'Nilai: 85 • Diposting kemarin',
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              0,
            ),
            child: _SectionTitle(
              title: 'Kelas Saya',
              subtitle: 'Mata kuliah aktif',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              20,
            ),
            child: _CourseCard(
              title: 'Pemrograman Web',
              meta1: '6 Modul',
              meta2: 'Dosen: Budi Santoso',
              progress: 0.75,
              onOpen: onOpenKelas,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderWithQuickMenu
    extends
        StatelessWidget {
  final VoidCallback onKelas;
  final VoidCallback onJadwal;
  final VoidCallback onTugas;
  final VoidCallback onNilai;

  const _HeaderWithQuickMenu({
    required this.onKelas,
    required this.onJadwal,
    required this.onTugas,
    required this.onNilai,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // tinggi header + ruang untuk quick menu
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none, // penting: biar ga kepotong
        children: [
          // background biru (header)
          Positioned.fill(
            child: _Header(),
          ),

          // ✅ "white sheet" di atas grid/menu, kiri-kanan rounded (cekung)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(
                  28,
                ),
                topRight: Radius.circular(
                  28,
                ),
              ),
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFF5F6FA,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(
                        0x14000000,
                      ),
                      blurRadius: 18,
                      offset: Offset(
                        0,
                        -6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // quick menu nempel di atas sheet (overlap tetap cantik)
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: _QuickMenuRow(
                onKelas: onKelas,
                onJadwal: onJadwal,
                onTugas: onTugas,
                onNilai: onNilai,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header
    extends
        StatelessWidget {
  static const Color _primary = Color(
    0xFF0E2E72,
  );
  static const Color _primary2 = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = FirebaseAuth.instance.currentUser;

    final Stream<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >
    stream =
        user ==
            null
        ? const Stream.empty()
        : FirebaseFirestore.instance
              .collection(
                'users',
              )
              .doc(
                user.uid,
              )
              .snapshots();

    return StreamBuilder<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      stream: stream,
      builder:
          (
            context,
            snap,
          ) {
            final data = snap.data?.data();
            final nama =
                (data?['nama'] ??
                        user?.displayName ??
                        'Fauzan')
                    .toString();

            return Container(
              height: 210,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primary2,
                    _primary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // wave/shape halus (simple)
                  Positioned(
                    left: -80,
                    top: 80,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -120,
                    top: -40,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      56,
                      18,
                      16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $nama',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                'Selamat datang di LMS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _Avatar(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _Avatar
    extends
        StatelessWidget {
  const _Avatar();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: 64, // ⬅️ lebih besar
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          0.15,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.8,
          ),
          width: 2.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _QuickMenuRow
    extends
        StatelessWidget {
  final VoidCallback onKelas;
  final VoidCallback onJadwal;
  final VoidCallback onTugas;
  final VoidCallback onNilai;

  const _QuickMenuRow({
    required this.onKelas,
    required this.onJadwal,
    required this.onTugas,
    required this.onNilai,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickMenuCard(
            title: 'Kelas Saya',
            icon: Icons.menu_book_rounded,
            color: const Color(
              0xFFFB6B4A,
            ),
            onTap: onKelas,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Jadwal',
            icon: Icons.event_available_rounded,
            color: const Color(
              0xFF2D7FF9,
            ),
            onTap: onJadwal,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Tugas',
            icon: Icons.assignment_rounded,
            color: const Color(
              0xFFFF9F2E,
            ),
            onTap: onTugas,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: _QuickMenuCard(
            title: 'Nilai',
            icon: Icons.school_rounded,
            color: const Color(
              0xFF2E9E67,
            ),
            onTap: onNilai,
          ),
        ),
      ],
    );
  }
}

class _QuickMenuCard
    extends
        StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickMenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Ink(
          height: 92,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              16,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(
                  0.25,
                ),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  8,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle
    extends
        StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(
                    0xFF1A2552,
                  ),
                ),
              ),
              if (subtitle !=
                  null) ...[
                const SizedBox(
                  height: 2,
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF6F7AA6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing !=
            null)
          trailing!,
      ],
    );
  }
}

class _PillButton
    extends
        StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        999,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFEAF0FF,
          ),
          borderRadius: BorderRadius.circular(
            999,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(
                  0xFF1B3C9E,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(
                0xFF1B3C9E,
              ),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard
    extends
        StatelessWidget {
  final String time;
  final String subject;
  final String room;
  final Color gradientA;
  final Color gradientB;

  const _ScheduleCard({
    required this.time,
    required this.subject,
    required this.room,
    required this.gradientA,
    required this.gradientB,
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
          18,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientA,
            gradientB,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: gradientA.withOpacity(
              0.25,
            ),
            blurRadius: 16,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            subject,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            room,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile
    extends
        StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
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
          16,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(
              0x11000000,
            ),
            blurRadius: 18,
            offset: Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(
                      0xFF1A2552,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF6F7AA6,
                    ),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(
              0xFF9AA6D1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard
    extends
        StatelessWidget {
  final String title;
  final String meta1;
  final String meta2;
  final double progress;
  final VoidCallback onOpen;

  const _CourseCard({
    required this.title,
    required this.meta1,
    required this.meta2,
    required this.progress,
    required this.onOpen,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final pct =
        (progress.clamp(
                  0,
                  1,
                ) *
                100)
            .round();

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x11000000,
                ),
                blurRadius: 18,
                offset: Offset(
                  0,
                  10,
                ),
              ),
            ],
            border: Border.all(
              color: Color(
                0x0D000000,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color:
                        const Color(
                          0xFF1B3C9E,
                        ).withOpacity(
                          0.08,
                        ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -10,
                bottom: -35,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color:
                        const Color(
                          0xFF1B3C9E,
                        ).withOpacity(
                          0.06,
                        ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 0,
                top: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/images/course.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  140,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: Color(
                          0xFF1A2552,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      meta1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Color(
                          0xFF6F7AA6,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      meta2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: Color(
                          0xFF6F7AA6,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Progress: $pct%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        color: Color(
                          0xFF1B3C9E,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        999,
                      ),
                      child: LinearProgressIndicator(
                        value: progress.clamp(
                          0,
                          1,
                        ),
                        minHeight: 8,
                        backgroundColor: const Color(
                          0xFFE9EDFF,
                        ),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(
                            0xFF1B3C9E,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar
    extends
        StatelessWidget {
  final double value; // 0..1
  const _ProgressBar({
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final pct =
        (value.clamp(
                  0,
                  1,
                ) *
                100)
            .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress: $pct%',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(
              0xFF1B3C9E,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            999,
          ),
          child: LinearProgressIndicator(
            value: value.clamp(
              0,
              1,
            ),
            minHeight: 10,
            backgroundColor: const Color(
              0xFFE9EDFF,
            ),
            valueColor: const AlwaysStoppedAnimation(
              Color(
                0xFF1B3C9E,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNav
    extends
        StatelessWidget {
  final int index;
  final ValueChanged<
    int
  >
  onChanged;

  const _BottomNav({
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1B3C9E,
            ),
            borderRadius: BorderRadius.circular(
              26,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x22000000,
                ),
                blurRadius: 24,
                offset: Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              26,
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: onChanged,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: Colors.white,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                color: Colors.white70,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_rounded,
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu_book_rounded,
                  ),
                  label: 'Materi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: 'Jadwal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat_bubble_rounded,
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_rounded,
                  ),
                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage
    extends
        StatelessWidget {
  final String title;
  const _PlaceholderPage({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      body: const Center(
        child: Text(
          'Halaman belum dibuat',
        ),
      ),
    );
  }
}

class _TodayScheduleCard
    extends
        StatelessWidget {
  final Color gradientA;
  final Color gradientB;
  final VoidCallback onOpenJadwal;

  const _TodayScheduleCard({
    required this.gradientA,
    required this.gradientB,
    required this.onOpenJadwal,
  });

  String _hariIndo(
    DateTime dt,
  ) {
    const map = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return map[dt.weekday] ??
        '-';
  }

  int _toMinutes(
    String s,
  ) {
    final parts = s.split(
      ':',
    );
    if (parts.length !=
        2)
      return 999999;
    final h =
        int.tryParse(
          parts[0],
        ) ??
        0;
    final m =
        int.tryParse(
          parts[1],
        ) ??
        0;
    return (h *
            60) +
        m;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid ==
        null) {
      return _ScheduleEmptyCard(
        text: 'Kamu belum login',
        onTap: onOpenJadwal,
      );
    }

    final db = FirebaseFirestore.instance;
    final hariIni = _hariIndo(
      DateTime.now(),
    );
    final nowMin =
        DateTime.now().hour *
            60 +
        DateTime.now().minute;

    // 1) Ambil semua kelas yang di-join user
    return StreamBuilder<
      QuerySnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      stream: db
          .collection(
            'kelas_mahasiswa',
          )
          .where(
            'mahasiswaId',
            isEqualTo: uid,
          )
          .snapshots(),
      builder:
          (
            context,
            relSnap,
          ) {
            if (relSnap.connectionState ==
                ConnectionState.waiting) {
              return const _ScheduleLoadingCard();
            }
            if (relSnap.hasError) {
              return _ScheduleEmptyCard(
                text: 'Error ambil kelas: ${relSnap.error}',
                onTap: onOpenJadwal,
              );
            }

            final relDocs =
                relSnap.data?.docs ??
                [];
            if (relDocs.isEmpty) {
              return _ScheduleEmptyCard(
                text: 'Kamu belum gabung kelas',
                onTap: onOpenJadwal,
              );
            }

            final kelasIds = relDocs
                .map(
                  (
                    e,
                  ) =>
                      (e.data()['kelasId'] ??
                              '')
                          .toString()
                          .trim(),
                )
                .where(
                  (
                    id,
                  ) => id.isNotEmpty,
                )
                .toList();

            if (kelasIds.isEmpty) {
              return _ScheduleEmptyCard(
                text: 'Data kelas kamu tidak valid',
                onTap: onOpenJadwal,
              );
            }

            // ⚠️ Firestore whereIn maksimal 30 item
            final whereInIds =
                kelasIds.length >
                    30
                ? kelasIds
                      .take(
                        30,
                      )
                      .toList()
                : kelasIds;

            // 2) Query semua jadwal hari ini untuk kelas-kelas tersebut (tanpa orderBy biar minim index)
            final q = db
                .collection(
                  'jadwal',
                )
                .where(
                  'hari',
                  isEqualTo: hariIni,
                )
                .where(
                  'kelasId',
                  whereIn: whereInIds,
                );

            return StreamBuilder<
              QuerySnapshot<
                Map<
                  String,
                  dynamic
                >
              >
            >(
              stream: q.snapshots(),
              builder:
                  (
                    context,
                    jadSnap,
                  ) {
                    if (jadSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const _ScheduleLoadingCard();
                    }
                    if (jadSnap.hasError) {
                      return _ScheduleEmptyCard(
                        text: 'Query jadwal error: ${jadSnap.error}',
                        onTap: onOpenJadwal,
                      );
                    }

                    final docs =
                        jadSnap.data?.docs ??
                        [];
                    if (docs.isEmpty) {
                      return _ScheduleEmptyCard(
                        text: 'Tidak ada jadwal hari ini',
                        onTap: onOpenJadwal,
                      );
                    }

                    // 3) Sort jadwal berdasarkan jamMulai
                    final sorted = [
                      ...docs,
                    ];
                    sorted.sort(
                      (
                        a,
                        b,
                      ) {
                        final am = _toMinutes(
                          (a.data()['jamMulai'] ??
                                  '')
                              .toString(),
                        );
                        final bm = _toMinutes(
                          (b.data()['jamMulai'] ??
                                  '')
                              .toString(),
                        );
                        return am.compareTo(
                          bm,
                        );
                      },
                    );

                    // 4) Pilih jadwal "berikutnya" (yang jamMulai >= sekarang)
                    QueryDocumentSnapshot<
                      Map<
                        String,
                        dynamic
                      >
                    >
                    picked = sorted.first;
                    for (final doc in sorted) {
                      final jm = _toMinutes(
                        (doc.data()['jamMulai'] ??
                                '')
                            .toString(),
                      );
                      if (jm >=
                          nowMin) {
                        picked = doc;
                        break;
                      }
                    }

                    final d = picked.data();
                    final jamMulai =
                        (d['jamMulai'] ??
                                '-')
                            .toString();
                    final jamSelesai =
                        (d['jamSelesai'] ??
                                '-')
                            .toString();
                    final matkul =
                        (d['mapel'] ??
                                d['mataKuliah'] ??
                                d['materi'] ??
                                '-')
                            .toString();
                    final ruang =
                        (d['ruang'] ??
                                d['kelasRuang'] ??
                                '-')
                            .toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                      onTap: onOpenJadwal,
                      child: _ScheduleCard(
                        time: '$jamMulai - $jamSelesai',
                        subject: matkul,
                        room: ruang,
                        gradientA: gradientA,
                        gradientB: gradientB,
                      ),
                    );
                  },
            );
          },
    );
  }
}

class _CardFromKelasId
    extends
        StatelessWidget {
  final String kelasId;
  final String hariIni;
  final Color gradientA;
  final Color gradientB;
  final VoidCallback onOpenJadwal;

  const _CardFromKelasId({
    required this.kelasId,
    required this.hariIni,
    required this.gradientA,
    required this.gradientB,
    required this.onOpenJadwal,
  });

  int _toMinutes(
    String s,
  ) {
    // "10:30" -> 630
    final parts = s.split(
      ':',
    );
    if (parts.length !=
        2)
      return 999999;
    final h =
        int.tryParse(
          parts[0],
        ) ??
        0;
    final m =
        int.tryParse(
          parts[1],
        ) ??
        0;
    return (h *
            60) +
        m;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final db = FirebaseFirestore.instance;

    // ambil nama kelas hanya buat tulisan fallback (opsional)
    return StreamBuilder<
      DocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >(
      stream: db
          .collection(
            'kelas',
          )
          .doc(
            kelasId,
          )
          .snapshots(),
      builder:
          (
            context,
            kelasSnap,
          ) {
            if (kelasSnap.connectionState ==
                ConnectionState.waiting) {
              return const _ScheduleLoadingCard();
            }
            final kelas =
                kelasSnap.data?.data() ??
                {};
            final kelasNama =
                (kelas['nama'] ??
                        '')
                    .toString()
                    .trim();

            // ✅ Query jadwal pakai kelasId + hari (TANPA orderBy) => biasanya aman tanpa index composite
            // Pastikan dokumen jadwal punya field: kelasId, hari, jamMulai, jamSelesai, ruang, mapel
            final q = db
                .collection(
                  'jadwal',
                )
                .where(
                  'kelasId',
                  isEqualTo: kelasId,
                )
                .where(
                  'hari',
                  isEqualTo: hariIni,
                );

            return StreamBuilder<
              QuerySnapshot<
                Map<
                  String,
                  dynamic
                >
              >
            >(
              stream: q.snapshots(),
              builder:
                  (
                    context,
                    jadSnap,
                  ) {
                    if (jadSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const _ScheduleLoadingCard();
                    }

                    if (jadSnap.hasError) {
                      // 🔥 biar keliatan error aslinya apa (index / permission / field)
                      return _ScheduleEmptyCard(
                        text: 'Query jadwal error: ${jadSnap.error}',
                        onTap: onOpenJadwal,
                      );
                    }

                    final docs =
                        jadSnap.data?.docs ??
                        [];
                    if (docs.isEmpty) {
                      return _ScheduleEmptyCard(
                        text: kelasNama.isEmpty
                            ? 'Tidak ada jadwal hari ini'
                            : 'Tidak ada jadwal hari ini ($kelasNama)',
                        onTap: onOpenJadwal,
                      );
                    }

                    // ✅ urutkan sendiri berdasarkan jamMulai
                    final sorted = [
                      ...docs,
                    ];
                    sorted.sort(
                      (
                        a,
                        b,
                      ) {
                        final am = _toMinutes(
                          (a.data()['jamMulai'] ??
                                  '')
                              .toString(),
                        );
                        final bm = _toMinutes(
                          (b.data()['jamMulai'] ??
                                  '')
                              .toString(),
                        );
                        return am.compareTo(
                          bm,
                        );
                      },
                    );

                    // ambil yang paling awal hari ini
                    final d = sorted.first.data();

                    final jamMulai =
                        (d['jamMulai'] ??
                                '-')
                            .toString();
                    final jamSelesai =
                        (d['jamSelesai'] ??
                                '-')
                            .toString();
                    final matkul =
                        (d['mapel'] ??
                                d['mataKuliah'] ??
                                d['materi'] ??
                                kelasNama)
                            .toString();
                    final ruang =
                        (d['ruang'] ??
                                d['kelasRuang'] ??
                                '-')
                            .toString();

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        18,
                      ),
                      onTap: onOpenJadwal,
                      child: _ScheduleCard(
                        time: '$jamMulai - $jamSelesai',
                        subject: matkul,
                        room: ruang,
                        gradientA: gradientA,
                        gradientB: gradientB,
                      ),
                    );
                  },
            );
          },
    );
  }
}

class _ScheduleLoadingCard
    extends
        StatelessWidget {
  const _ScheduleLoadingCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 92,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(
            0x0D000000,
          ),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            'Memuat jadwal hari ini...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(
                0xFF6F7AA6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEmptyCard
    extends
        StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ScheduleEmptyCard({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        18,
      ),
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color: const Color(
              0x0D000000,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              color: Color(
                0xFF6F7AA6,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(
                    0xFF6F7AA6,
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(
                0xFF9AA6D1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
