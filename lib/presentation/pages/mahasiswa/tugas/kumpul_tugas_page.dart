// lib/presentation/pages/mahasiswa/tugas/kumpul_tugas_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

// ===================== THEME (samakan dengan TugasPage) =====================
const Color
kBg = Color(
  0xFFF5F6FA,
);
const Color
kTextDark = Color(
  0xFF1A2552,
);
const Color
kMuted = Color(
  0xFF6F7AA6,
);
const Color
kPrimary = Color(
  0xFF1B3C9E,
);

const double
s8 = 8;
const double
s12 = 12;
const double
s16 = 16;
const double
s24 = 24;

class KumpulTugasPage
    extends
        StatelessWidget {
  final String tugasId;
  final String judulTugas;
  final String deskripsi;

  const KumpulTugasPage({
    super.key,
    required this.tugasId,
    required this.judulTugas,
    required this.deskripsi,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .watch<
          MahasiswaViewModel
        >();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        centerTitle: false,
        title: Text(
          'Kumpul Tugas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body:
          FutureBuilder<
            bool
          >(
            future: vm.sudahKumpul(
              tugasId,
            ),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  final loading =
                      snapshot.connectionState ==
                      ConnectionState.waiting;
                  final error = snapshot.hasError;
                  final sudah =
                      snapshot.data ??
                      false;

                  if (loading) {
                    return const _PageLoading();
                  }

                  if (error) {
                    return _PageError(
                      message: '${snapshot.error}',
                      onRetry: () {
                        // FutureBuilder akan rerun kalau widget rebuild
                        (context
                                as Element)
                            .markNeedsBuild();
                      },
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      s16,
                      s16,
                      s16,
                      24,
                    ),
                    children: [
                      _HeaderCard(
                        title: judulTugas,
                        subtitle: 'ID: $tugasId',
                        submitted: sudah,
                      ),
                      const SizedBox(
                        height: s16,
                      ),

                      _SectionCard(
                        title: 'Deskripsi Tugas',
                        icon: Icons.description_rounded,
                        child: Text(
                          deskripsi.trim().isEmpty
                              ? 'Tidak ada deskripsi.'
                              : deskripsi,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.6,
                            height: 1.45,
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: s12,
                      ),

                      _SectionCard(
                        title: 'Status Pengumpulan',
                        icon: sudah
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_bottom_rounded,
                        child: Row(
                          children: [
                            _MiniBadge(
                              label: sudah
                                  ? 'Sudah Dikumpulkan'
                                  : 'Belum Dikumpulkan',
                              icon: sudah
                                  ? Icons.check_rounded
                                  : Icons.upload_rounded,
                            ),
                            const Spacer(),
                            _StatusBadge(
                              submitted: sudah,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: s16,
                      ),

                      _SectionCard(
                        title: 'Aksi',
                        icon: Icons.upload_file_rounded,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: sudah
                                    ? null
                                    : () async {
                                        await vm.kumpulTugas(
                                          tugasId,
                                        );
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  sudah
                                      ? Icons.check_rounded
                                      : Icons.upload_rounded,
                                ),
                                label: Text(
                                  sudah
                                      ? 'Sudah Dikumpulkan'
                                      : 'Kumpulkan Tugas',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              sudah
                                  ? 'Kamu sudah mengumpulkan tugas ini.'
                                  : 'Tekan tombol di atas untuk mengumpulkan tugas.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                                color: kMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
          ),
    );
  }
}

// ======================================================================
// UI COMPONENTS (samakan vibes dengan TugasPage)
// ======================================================================
class _HeaderCard
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final bool submitted;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.submitted,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        s16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        gradient: LinearGradient(
          colors: [
            kPrimary.withOpacity(
              0.10,
            ),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: kPrimary.withOpacity(
            0.08,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              submitted
                  ? Icons.check_circle_rounded
                  : Icons.assignment_rounded,
              color: kPrimary,
            ),
          ),
          const SizedBox(
            width: s12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty
                      ? '-'
                      : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          _StatusBadge(
            submitted: submitted,
          ),
        ],
      ),
    );
  }
}

class _SectionCard
    extends
        StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius: 18,
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(
                    0.10,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: kPrimary,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                    fontSize: 14.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge
    extends
        StatelessWidget {
  final bool submitted;
  const _StatusBadge({
    required this.submitted,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final label = submitted
        ? 'SUDAH'
        : 'BELUM';
    final Color c = submitted
        ? const Color(
            0xFF22C55E,
          )
        : kPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: c.withOpacity(
          0.10,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: c.withOpacity(
            0.20,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.6,
          color: c,
        ),
      ),
    );
  }
}

class _MiniBadge
    extends
        StatelessWidget {
  final String label;
  final IconData icon;
  const _MiniBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF7F8FD,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: kMuted,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageLoading
    extends
        StatelessWidget {
  const _PageLoading();

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        s16,
        s16,
        s16,
        24,
      ),
      children: [
        Container(
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: s16,
        ),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              22,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: s16,
        ),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              22,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: s16,
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}

class _PageError
    extends
        StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _PageError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: kMuted,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              'Terjadi kesalahan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: kTextDark,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: kMuted,
              ),
            ),
            const SizedBox(
              height: s16,
            ),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                'Coba lagi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
