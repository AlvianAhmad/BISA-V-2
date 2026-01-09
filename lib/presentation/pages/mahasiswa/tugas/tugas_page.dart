// lib/presentation/pages/mahasiswa/tugas/tugas_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';
import 'kumpul_tugas_page.dart';

// ===================== THEME (samakan dengan MateriPage) =====================
const Color kBg = Color(0xFFF5F6FA);
const Color kTextDark = Color(0xFF1A2552);
const Color kMuted = Color(0xFF6F7AA6);
const Color kPrimary = Color(0xFF1B3C9E);

const double s8 = 8;
const double s12 = 12;
const double s16 = 16;
const double s24 = 24;

enum TugasFilter { semua, deadlineHariIni, belumDikumpulkan }

class TugasPage extends StatefulWidget {
  final String kelasNama;
  const TugasPage({super.key, required this.kelasNama});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final TextEditingController _search = TextEditingController();
  TugasFilter _filter = TugasFilter.semua;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ---------------------- DEADLINE HELPERS ----------------------
  DateTime? _readDeadline(Map<String, dynamic> data) {
    // Aman kalau nama field deadline kamu beda-beda
    final dynamic raw =
        data['deadline'] ??
        data['dueDate'] ??
        data['tanggalDeadline'] ??
        data['batasWaktu'];

    if (raw == null) return null;

    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw);

    return null;
  }

  bool _isToday(DateTime d) => DateUtils.isSameDay(d, DateTime.now());

  String _fmtDeadline(DateTime d) {
    // contoh: 07 Jan 2026 • 23:59
    return DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(d);
  }

  // ---------------------- STATUS PENGUMPULAN ----------------------
  /// Cek apakah user sudah mengumpulkan tugas ini.
  /// Asumsi path: tugas/{tugasId}/pengumpulan/{uid}
  /// Kalau di project kamu beda (misal "submissions"), ganti "pengumpulan" di sini.
  Stream<bool> _isSubmittedStream(String tugasId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('tugas') // <- pastikan koleksi tugas kamu memang "tugas"
        .doc(tugasId)
        .collection('pengumpulan') // <- ganti kalau nama subcollection beda
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ---------------------- FILTER + SEARCH ----------------------
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyUiFilter(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final q = _search.text.trim().toLowerCase();
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> out = docs;

    // filter: deadline hari ini (sync)
    if (_filter == TugasFilter.deadlineHariIni) {
      out = out.where((d) {
        final deadline = _readDeadline(d.data());
        return deadline != null && _isToday(deadline);
      });
    }

    // NOTE:
    // filter "belumDikumpulkan" butuh cek Firestore per user (async),
    // jadi difilter di level item widget (lihat StreamBuilder di bawah).

    // search: judul + deskripsi
    if (q.isNotEmpty) {
      out = out.where((d) {
        final data = d.data();
        final judul = (data['judul'] ?? '').toString();
        final desc = (data['deskripsi'] ?? '').toString();
        final s = '$judul $desc'.toLowerCase();
        return s.contains(q);
      });
    }

    return out.toList();
  }

  // ---------------------- DETAIL BOTTOMSHEET ----------------------
  Future<void> _openTugasDetail({
    required BuildContext context,
    required String tugasId,
    required String judul,
    required String deskripsi,
    required DateTime? deadline,
    required bool submitted,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.70,
          minChildSize: 0.40,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            judul,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: kTextDark,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.close_rounded, color: kMuted),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      children: [
                        _DetailSection(
                          title: 'Kelas',
                          icon: Icons.school_rounded,
                          child: Text(
                            widget.kelasNama,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.6,
                              height: 1.35,
                              color: kTextDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _DetailSection(
                          title: 'Status',
                          icon: submitted
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_bottom_rounded,
                          child: Text(
                            submitted
                                ? 'Sudah dikumpulkan'
                                : 'Belum dikumpulkan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.6,
                              height: 1.35,
                              color: kTextDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _DetailSection(
                          title: 'Deadline',
                          icon: Icons.schedule_rounded,
                          child: Text(
                            deadline == null
                                ? 'Tidak ada deadline.'
                                : _fmtDeadline(deadline),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.6,
                              height: 1.35,
                              color: kTextDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _DetailSection(
                          title: 'Deskripsi Tugas',
                          icon: Icons.description_rounded,
                          child: Text(
                            deskripsi.trim().isEmpty
                                ? 'Tidak ada deskripsi.'
                                : deskripsi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.6,
                              height: 1.35,
                              color: kTextDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _DetailSection(
                          title: 'Aksi',
                          icon: Icons.upload_rounded,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: submitted
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KumpulTugasPage(
                                            tugasId: tugasId,
                                            judulTugas: judul,
                                            deskripsi: deskripsi,
                                          ),
                                        ),
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
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(
                                submitted
                                    ? Icons.check_rounded
                                    : Icons.upload_file_rounded,
                              ),
                              label: Text(
                                submitted
                                    ? 'Sudah Dikumpulkan'
                                    : 'Kumpul Tugas',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          'Tugas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: vm.tugasByKelasNama(widget.kelasNama),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _TugasLoading();
          }

          if (snapshot.hasError) {
            return _TugasError(
              message: '${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final docs = snapshot.data?.docs ?? const [];
          final uiDocs = _applyUiFilter(docs);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(s16, s16, s16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                TugasHeader(total: docs.length, kelasNama: widget.kelasNama),
                const SizedBox(height: s16),

                _SearchBar(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  onClear: () {
                    _search.clear();
                    setState(() {});
                  },
                ),
                const SizedBox(height: s12),

                _FilterChips(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: s16),

                if (docs.isEmpty)
                  _EmptyState(onRefresh: () => setState(() {}))
                else if (uiDocs.isEmpty)
                  _NoResultState(
                    title: _filter == TugasFilter.deadlineHariIni
                        ? 'Tidak ada tugas dengan deadline hari ini'
                        : 'Tugas tidak ditemukan',
                    subtitle: _filter == TugasFilter.deadlineHariIni
                        ? 'Coba ubah filter ke "Semua" atau gunakan pencarian.'
                        : 'Coba ubah kata kunci atau reset filter.',
                    onReset: () {
                      _search.clear();
                      setState(() => _filter = TugasFilter.semua);
                    },
                  )
                else
                  ...List.generate(uiDocs.length, (index) {
                    final doc = uiDocs[index];
                    final data = doc.data();

                    final judul = (data['judul'] ?? '-').toString();
                    final deskripsi = (data['deskripsi'] ?? '').toString();

                    final deadline = _readDeadline(data);
                    final deadlineText = deadline == null
                        ? null
                        : _fmtDeadline(deadline);
                    final isToday = deadline != null && _isToday(deadline);

                    // ✅ cek status pengumpulan per-user (async)
                    return StreamBuilder<bool>(
                      stream: _isSubmittedStream(doc.id),
                      builder: (context, subSnap) {
                        final submitted = subSnap.data ?? false;

                        // ✅ FILTER: belum dikumpulkan
                        if (_filter == TugasFilter.belumDikumpulkan &&
                            submitted) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: s12),
                          child: _TugasCardModern(
                            title: judul.isEmpty ? '-' : judul,
                            subtitle: deskripsi.trim().isEmpty
                                ? 'Tidak ada deskripsi'
                                : deskripsi,
                            deadlineText: deadlineText,
                            isDeadlineToday: isToday,
                            submitted: submitted,
                            onTap: () => _openTugasDetail(
                              context: context,
                              tugasId: doc.id,
                              judul: judul,
                              deskripsi: deskripsi,
                              deadline: deadline,
                              submitted: submitted,
                            ),
                            onPrimaryAction: submitted
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => KumpulTugasPage(
                                          tugasId: doc.id,
                                          judulTugas: judul,
                                          deskripsi: deskripsi,
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// HEADER (mirip MateriHeader)
// ======================================================================
class TugasHeader extends StatelessWidget {
  final int total;
  final String kelasNama;
  const TugasHeader({super.key, required this.total, required this.kelasNama});

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_rounded, color: kPrimary),
          ),
          const SizedBox(width: s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas Kelas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total tugas • $kelasNama',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded, color: kPrimary),
        ],
      ),
    );
  }
}

// ======================================================================
// SEARCH BAR
// ======================================================================
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: s12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _focus ? kPrimary.withOpacity(0.35) : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_focus ? 0.07 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focus = v),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: _focus ? kPrimary : kMuted),
            const SizedBox(width: s8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari tugas...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: kMuted.withOpacity(0.9),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: widget.controller.text.trim().isEmpty ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 160),
              child: IconButton(
                tooltip: 'Hapus',
                onPressed: widget.controller.text.trim().isEmpty
                    ? null
                    : widget.onClear,
                icon: const Icon(Icons.close_rounded),
                color: kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// FILTER CHIPS: Semua / Deadline Hari Ini / Belum Dikumpulkan
// ======================================================================
class _FilterChips extends StatelessWidget {
  final TugasFilter value;
  final ValueChanged<TugasFilter> onChanged;

  const _FilterChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: s8,
      runSpacing: s8,
      children: [
        _chip(
          label: 'Semua',
          selected: value == TugasFilter.semua,
          onTap: () => onChanged(TugasFilter.semua),
          icon: Icons.apps_rounded,
        ),
        _chip(
          label: 'Deadline Hari Ini',
          selected: value == TugasFilter.deadlineHariIni,
          onTap: () => onChanged(TugasFilter.deadlineHariIni),
          icon: Icons.today_rounded,
        ),
        _chip(
          label: 'Belum Dikumpulkan',
          selected: value == TugasFilter.belumDikumpulkan,
          onTap: () => onChanged(TugasFilter.belumDikumpulkan),
          icon: Icons.hourglass_bottom_rounded,
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? kPrimary.withOpacity(0.35) : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.06 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? kPrimary : kMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? kPrimary : kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// CARD MODERN + DEADLINE + STATUS BADGE
// ======================================================================
class _TugasCardModern extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? deadlineText;
  final bool isDeadlineToday;
  final bool submitted;
  final VoidCallback onTap;
  final VoidCallback? onPrimaryAction;

  const _TugasCardModern({
    required this.title,
    required this.subtitle,
    required this.deadlineText,
    required this.isDeadlineToday,
    required this.submitted,
    required this.onTap,
    required this.onPrimaryAction,
  });

  @override
  State<_TugasCardModern> createState() => _TugasCardModernState();
}

class _TugasCardModernState extends State<_TugasCardModern> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.06), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.submitted
                          ? Icons.check_circle_rounded
                          : Icons.assignment_rounded,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(width: s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.5,
                                  color: kTextDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(submitted: widget.submitted),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.8,
                            color: kMuted,
                            height: 1.35,
                          ),
                        ),

                        if (widget.deadlineText != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: kMuted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.deadlineText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.2,
                                    color: kTextDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: s12),
                        Row(
                          children: [
                            _MiniBadge(
                              label: widget.submitted
                                  ? 'Sudah Dikumpulkan'
                                  : (widget.isDeadlineToday
                                        ? 'Deadline Hari Ini'
                                        : 'Belum Dikumpulkan'),
                              icon: widget.submitted
                                  ? Icons.check_rounded
                                  : (widget.isDeadlineToday
                                        ? Icons.today_rounded
                                        : Icons.hourglass_bottom_rounded),
                            ),
                            const Spacer(),
                            _PrimaryButton(
                              label: widget.submitted ? 'Terkumpul' : 'Kumpul',
                              onPressed: widget.onPrimaryAction,
                              icon: widget.submitted
                                  ? Icons.check_rounded
                                  : Icons.upload_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool submitted;
  const _StatusBadge({required this.submitted});

  @override
  Widget build(BuildContext context) {
    final label = submitted ? 'SUDAH DIKUMPULKAN' : 'BELUM DIKUMPULKAN';
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
          fontWeight: FontWeight.w800,
          fontSize: 10.3,
          letterSpacing: 0.35,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// DETAIL UI COMPONENTS
// ======================================================================
class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ======================================================================
// EMPTY + LOADING + ERROR + NO RESULT
// ======================================================================
class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 48,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: s16),
          Text(
            'Belum ada tugas',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: kTextDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tugas akan muncul setelah dosen menambahkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: s16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Refresh',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TugasLoading extends StatelessWidget {
  const _TugasLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(s16, s16, s16, 24),
      children: [
        Container(
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: s16),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: s16),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: s12),
            child: Container(
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: s8),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _TugasError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _TugasError({required this.message, required this.onRetry});

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

class _NoResultState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onReset;

  const _NoResultState({
    required this.title,
    required this.subtitle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(s24),
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
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: s16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: kTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kMuted,
            ),
          ),
          const SizedBox(height: s16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: BorderSide(color: kPrimary.withOpacity(0.35)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                'Reset',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
