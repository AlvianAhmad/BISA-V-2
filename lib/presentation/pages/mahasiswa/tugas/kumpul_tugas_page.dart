// lib/presentation/pages/mahasiswa/tugas/kumpul_tugas_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

// ===================== THEME =====================
const Color kBg = Color(0xFFF5F6FA);
const Color kTextDark = Color(0xFF1A2552);
const Color kMuted = Color(0xFF6F7AA6);
const Color kPrimary = Color(0xFF1B3C9E);

const double s8 = 8;
const double s12 = 12;
const double s16 = 16;
const double s24 = 24;

class KumpulTugasPage extends StatefulWidget {
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
  State<KumpulTugasPage> createState() => _KumpulTugasPageState();
}

class _KumpulTugasPageState extends State<KumpulTugasPage> {
  final linkC = TextEditingController();
  final noteC = TextEditingController();

  bool submitting = false;
  String? err;

  // ✅ buat "trigger" supaya FutureBuilder rerun
  DateTime _refresh = DateTime.now();

  @override
  void dispose() {
    linkC.dispose();
    noteC.dispose();
    super.dispose();
  }

  bool _isValidDriveUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return false;

    // Accept:
    // - drive.google.com/file/d/.../view
    // - drive.google.com/open?id=...
    // - docs.google.com/document/d/...
    // - docs.google.com/spreadsheets/d/...
    // - docs.google.com/presentation/d/...
    return RegExp(r'^(https?:\/\/)?(drive|docs)\.google\.com\/').hasMatch(u);
  }

  void _triggerRefresh() {
    setState(() => _refresh = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MahasiswaViewModel>();

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
      body: FutureBuilder<bool>(
        // ✅ pakai _refresh agar future rerun
        future: vm.sudahKumpul(
          '${widget.tugasId}::${_refresh.toIso8601String()}',
          // trik: param berubah -> FutureBuilder rerun.
          // tapi method sudahKumpul kamu butuh tugasId murni, jadi kita ambil sebelum '::'
        ),
        builder: (context, snap) {
          // karena trik di atas, kita perlu panggil future yang benar:
          // cara aman: jangan ubah signature. lebih baik: gunakan FutureBuilder key.
          // jadi kita akan perbaiki: FutureBuilder diganti menjadi KeyedSubtree di bawah.
          return _KeyedBody(
            key: ValueKey(_refresh.toIso8601String()),
            tugasId: widget.tugasId,
            vm: vm,
            judul: widget.judulTugas,
            deskripsi: widget.deskripsi,
            linkC: linkC,
            noteC: noteC,
            submitting: submitting,
            err: err,
            isValidDrive: _isValidDriveUrl,
            onSetErr: (v) => setState(() => err = v),
            onSetSubmitting: (v) => setState(() => submitting = v),
            onRefresh: _triggerRefresh,
          );
        },
      ),
    );
  }
}

/// ==================== BODY (keyed supaya refresh future) ====================
class _KeyedBody extends StatelessWidget {
  final String tugasId;
  final MahasiswaViewModel vm;
  final String judul;
  final String deskripsi;

  final TextEditingController linkC;
  final TextEditingController noteC;

  final bool submitting;
  final String? err;

  final bool Function(String url) isValidDrive;
  final void Function(String? v) onSetErr;
  final void Function(bool v) onSetSubmitting;
  final VoidCallback onRefresh;

  const _KeyedBody({
    super.key,
    required this.tugasId,
    required this.vm,
    required this.judul,
    required this.deskripsi,
    required this.linkC,
    required this.noteC,
    required this.submitting,
    required this.err,
    required this.isValidDrive,
    required this.onSetErr,
    required this.onSetSubmitting,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: vm.sudahKumpul(tugasId),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final sudah = snap.data ?? false;

        if (loading) return const _PageLoading();
        if (snap.hasError) {
          return _PageError(
            message: '${snap.error}',
            onRetry: () => (context as Element).markNeedsBuild(),
          );
        }

        // ✅ detailPengumpulan hanya kalau sudah submit
        return FutureBuilder<Map<String, dynamic>?>(
          future: sudah ? vm.detailPengumpulan(tugasId) : Future.value(null),
          builder: (context, snap2) {
            if (snap2.connectionState == ConnectionState.waiting) {
              // kalau sudah submit, tunggu data linknya
              if (sudah) return const _PageLoading();
            }

            final data = snap2.data;

            final submittedUrl = (data?['url'] ?? '').toString();
            final submittedNote = (data?['catatan'] ?? '').toString();

            return ListView(
              padding: const EdgeInsets.fromLTRB(s16, s16, s16, 24),
              children: [
                _HeaderCard(
                  title: judul,
                  subtitle: 'ID: $tugasId',
                  submitted: sudah,
                ),
                const SizedBox(height: s16),

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
                const SizedBox(height: s12),

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
                      _StatusBadge(submitted: sudah),
                    ],
                  ),
                ),

                const SizedBox(height: s12),

                _SectionCard(
                  title: 'Link Tugas (Google Drive)',
                  icon: Icons.link_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sudah && submittedUrl.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: kPrimary.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Link yang sudah dikumpulkan:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  color: kTextDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                submittedUrl,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary,
                                ),
                              ),
                              if (submittedNote.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Catatan: $submittedNote',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    color: kMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (err != null) ...[
                        _ErrorBox(text: err!),
                        const SizedBox(height: 10),
                      ],

                      TextField(
                        controller: linkC,
                        enabled: !sudah && !submitting,
                        decoration: InputDecoration(
                          labelText: 'Tempel link Google Drive di sini',
                          hintText: 'https://drive.google.com/...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: noteC,
                        enabled: !sudah && !submitting,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pastikan link Drive kamu sudah di-set: "Anyone with the link can view".',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.2,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: kMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: s16),

                _SectionCard(
                  title: 'Aksi',
                  icon: Icons.upload_file_rounded,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (sudah || submitting)
                              ? null
                              : () async {
                                  onSetErr(null);

                                  final url = linkC.text.trim();
                                  if (url.isEmpty) {
                                    onSetErr('Link wajib diisi.');
                                    return;
                                  }
                                  if (!isValidDrive(url)) {
                                    onSetErr(
                                      'Link harus dari Google Drive / Google Docs.',
                                    );
                                    return;
                                  }

                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  try {
                                    onSetSubmitting(true);

                                    await vm.kumpulTugasLink(
                                      tugasId: tugasId,
                                      url: url,
                                      catatan: noteC.text,
                                    );

                                    if (!context.mounted) return;

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tugas berhasil dikumpulkan!',
                                        ),
                                      ),
                                    );

                                    // ✅ refresh supaya status "sudah" berubah
                                    onRefresh();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    onSetErr('Gagal mengumpulkan: $e');
                                  } finally {
                                    if (context.mounted) onSetSubmitting(false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: submitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  sudah
                                      ? Icons.check_rounded
                                      : Icons.upload_rounded,
                                ),
                          label: Text(
                            sudah ? 'Sudah Dikumpulkan' : 'Kumpulkan Tugas',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sudah
                            ? 'Kamu sudah mengumpulkan tugas ini.'
                            : 'Tempel link Drive lalu tekan tombol untuk mengumpulkan.',
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
        );
      },
    );
  }
}

// ======================================================================
// UI COMPONENTS
// ======================================================================
class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool submitted;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(s16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [kPrimary.withOpacity(0.10), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: kPrimary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              submitted ? Icons.check_circle_rounded : Icons.assignment_rounded,
              color: kPrimary,
            ),
          ),
          const SizedBox(width: s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '-' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
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
          const SizedBox(width: 10),
          _StatusBadge(submitted: submitted),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
                  color: kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: kPrimary),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool submitted;
  const _StatusBadge({required this.submitted});

  @override
  Widget build(BuildContext context) {
    final label = submitted ? 'SUDAH' : 'BELUM';
    final Color c = submitted ? const Color(0xFF22C55E) : kPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.20)),
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

class _MiniBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MiniBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kMuted),
          const SizedBox(width: 6),
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

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageLoading extends StatelessWidget {
  const _PageLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}

class _PageError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _PageError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: kMuted),
            const SizedBox(height: 12),
            Text(
              'Terjadi kesalahan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: kMuted,
              ),
            ),
            const SizedBox(height: s16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Coba lagi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
