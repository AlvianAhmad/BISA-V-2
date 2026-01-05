// lib/presentation/pages/mahasiswa/materi/materi_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/mahasiswa/materi_viewmodel.dart';

// ===================== THEME (elegan + kampus/LMS) =====================
const Color kBg = Color(0xFFF5F6FA);
const Color kTextDark = Color(0xFF1A2552);
const Color kMuted = Color(0xFF6F7AA6);
const Color kPrimary = Color(0xFF1B3C9E);

const double s8 = 8;
const double s12 = 12;
const double s16 = 16;
const double s24 = 24;

enum MateriFilter { semua, denganFile, tanpaFile }

class MateriPage extends StatefulWidget {
  final String kelasId;
  const MateriPage({super.key, required this.kelasId});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  final TextEditingController _search = TextEditingController();
  MateriFilter _filter = MateriFilter.semua;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _hasFile(Materi m) => (m.fileUrl?.trim().isNotEmpty ?? false);

  // Prefer pakai fileType dari Firestore kalau ada
  String _guessType(Materi m) {
    final ft = (m.fileType ?? '').toLowerCase().trim();
    if (ft.isNotEmpty) {
      if (ft == 'pdf') return 'PDF';
      if (ft == 'doc' || ft == 'docx') return 'WORD';
      if (ft == 'xls' || ft == 'xlsx') return 'EXCEL';
      if (ft == 'ppt' || ft == 'pptx') return 'PPT';
      if (ft == 'jpg' || ft == 'jpeg' || ft == 'png') return 'GAMBAR';
      if (ft == 'mp4') return 'VIDEO';
    }

    // fallback heuristik dari judul/deskripsi/url
    final t = '${m.judul} ${m.deskripsi} ${m.fileUrl ?? ''}'.toLowerCase();
    if (t.contains('.pdf') || t.contains('pdf')) return 'PDF';
    if (t.contains('.doc') || t.contains('.docx') || t.contains('doc'))
      return 'WORD';
    if (t.contains('.xls') || t.contains('.xlsx') || t.contains('excel'))
      return 'EXCEL';
    if (t.contains('.ppt') || t.contains('.pptx') || t.contains('ppt'))
      return 'PPT';
    if (t.contains('.jpg') || t.contains('.jpeg') || t.contains('.png'))
      return 'GAMBAR';
    if (t.contains('.mp4') || t.contains('video') || t.contains('youtube'))
      return 'VIDEO';
    return 'MATERI';
  }

  IconData _fileIcon(String? fileType, {bool fallbackBook = false}) {
    final ft = (fileType ?? '').toLowerCase();
    switch (ft) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      case 'mp4':
        return Icons.play_circle_rounded;
      default:
        return fallbackBook
            ? Icons.menu_book_rounded
            : Icons.attach_file_rounded;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak bisa membuka file')));
    }
  }

  Future<void> _openMateriDetail(BuildContext context, Materi m) async {
    final hasFile = _hasFile(m);
    final label = _guessType(m);

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
                          child: Icon(
                            _fileIcon(m.fileType, fallbackBook: true),
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.judul,
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
                          title: 'Deskripsi Materi',
                          icon: Icons.description_rounded,
                          child: Text(
                            (m.deskripsi).toString().trim().isEmpty
                                ? 'Tidak ada deskripsi.'
                                : m.deskripsi,
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
                          title: 'Tipe',
                          icon: Icons.category_rounded,
                          child: _TypeBadge(label: label),
                        ),

                        if (hasFile) ...[
                          const SizedBox(height: 12),
                          _DetailSection(
                            title: 'File Materi',
                            icon: Icons.attach_file_rounded,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FD),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(_fileIcon(m.fileType), color: kPrimary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _prettyFileName(
                                            m.fileUrl,
                                            m.fileType,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w900,
                                            color: kTextDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Ketuk tombol untuk membuka / download',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.2,
                                            color: kMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _openUrl(m.fileUrl!),
                                    child: Ink(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPrimary,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: kPrimary.withOpacity(0.22),
                                            blurRadius: 14,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.download_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Buka',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          _HintBox(
                            text: 'Materi ini tidak memiliki file lampiran.',
                          ),
                        ],
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

  List<Materi> _applyUiFilter(List<Materi> list) {
    final q = _search.text.trim().toLowerCase();

    Iterable<Materi> out = list;

    if (_filter == MateriFilter.denganFile) {
      out = out.where(_hasFile);
    } else if (_filter == MateriFilter.tanpaFile) {
      out = out.where((m) => !_hasFile(m));
    }

    if (q.isNotEmpty) {
      out = out.where((m) {
        final s = '${m.judul} ${m.deskripsi}'.toLowerCase();
        return s.contains(q);
      });
    }

    return out.toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MateriViewModel>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        centerTitle: false,
        title: Text(
          'Materi',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: StreamBuilder<List<Materi>>(
        stream: vm.getMateriByKelas(widget.kelasId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _MateriLoading();
          }

          if (snapshot.hasError) {
            return _MateriError(
              message: '${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final rawList = snapshot.data ?? const <Materi>[];
          final uiList = _applyUiFilter(rawList);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(s16, s16, s16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                MateriHeader(total: rawList.length),
                const SizedBox(height: s16),

                MateriSearchBar(
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

                if (rawList.isEmpty)
                  MateriEmptyState(onRefresh: () => setState(() {}))
                else if (uiList.isEmpty)
                  _NoResultState(
                    onReset: () {
                      _search.clear();
                      setState(() => _filter = MateriFilter.semua);
                    },
                  )
                else
                  ...List.generate(uiList.length, (index) {
                    final m = uiList[index];
                    final judul = (m.judul.isEmpty) ? '-' : m.judul;
                    final deskripsi = (m.deskripsi.isEmpty)
                        ? 'Tidak ada deskripsi'
                        : m.deskripsi;

                    final hasFile = _hasFile(m);
                    final type = _guessType(m);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: s12),
                      child: MateriCardModern(
                        index: index,
                        title: judul,
                        subtitle: deskripsi,
                        hasFile: hasFile,
                        typeLabel: type,
                        onTap: () => _openMateriDetail(context, m),
                        onPrimaryAction: hasFile
                            ? () => _openUrl(m.fileUrl!)
                            : null,
                      ),
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
// HEADER
// ======================================================================
class MateriHeader extends StatelessWidget {
  final int total;
  const MateriHeader({super.key, required this.total});

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
            child: const Icon(Icons.menu_book_rounded, color: kPrimary),
          ),
          const SizedBox(width: s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materi Pembelajaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total materi tersedia',
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
// SEARCH BAR (UI only)
// ======================================================================
class MateriSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MateriSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<MateriSearchBar> createState() => _MateriSearchBarState();
}

class _MateriSearchBarState extends State<MateriSearchBar> {
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
                  hintText: 'Cari materi...',
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
// FILTER CHIPS
// ======================================================================
class _FilterChips extends StatelessWidget {
  final MateriFilter value;
  final ValueChanged<MateriFilter> onChanged;

  const _FilterChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: s8,
      runSpacing: s8,
      children: [
        _chip(
          label: 'Semua',
          selected: value == MateriFilter.semua,
          onTap: () => onChanged(MateriFilter.semua),
          icon: Icons.apps_rounded,
        ),
        _chip(
          label: 'Dengan File',
          selected: value == MateriFilter.denganFile,
          onTap: () => onChanged(MateriFilter.denganFile),
          icon: Icons.attach_file_rounded,
        ),
        _chip(
          label: 'Tanpa File',
          selected: value == MateriFilter.tanpaFile,
          onTap: () => onChanged(MateriFilter.tanpaFile),
          icon: Icons.text_snippet_rounded,
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
// CARD MODERN (premium)
// ======================================================================
class MateriCardModern extends StatefulWidget {
  final int index;
  final String title;
  final String subtitle;
  final bool hasFile;
  final String typeLabel;
  final VoidCallback onTap;
  final VoidCallback? onPrimaryAction;

  const MateriCardModern({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.hasFile,
    required this.typeLabel,
    required this.onTap,
    this.onPrimaryAction,
  });

  @override
  State<MateriCardModern> createState() => _MateriCardModernState();
}

class _MateriCardModernState extends State<MateriCardModern> {
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
                      widget.hasFile
                          ? Icons.attach_file_rounded
                          : Icons.menu_book_rounded,
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
                            _TypeBadge(label: widget.typeLabel),
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
                        const SizedBox(height: s12),

                        Row(
                          children: [
                            if (!widget.hasFile)
                              const _MiniBadge(
                                label: 'Text Only',
                                icon: Icons.text_snippet_rounded,
                              )
                            else
                              const _MiniBadge(
                                label: 'Ada File',
                                icon: Icons.attach_file_rounded,
                              ),
                            const Spacer(),
                            if (widget.hasFile)
                              _PrimaryButton(
                                label: 'Lihat',
                                onPressed: widget.onPrimaryAction,
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: kMuted.withOpacity(0.9),
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

class _TypeBadge extends StatelessWidget {
  final String label;
  const _TypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final up = label.toUpperCase();
    final isVideo = up == 'VIDEO';
    final isPdf = up == 'PDF';
    final isWord = up == 'WORD';
    final isExcel = up == 'EXCEL';
    final isPpt = up == 'PPT';

    Color c = kPrimary;
    if (isVideo) c = const Color(0xFF7C3AED);
    if (isPdf) c = const Color(0xFF0EA5E9);
    if (isWord) c = const Color(0xFF22C55E);
    if (isExcel) c = const Color(0xFFF59E0B);
    if (isPpt) c = const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.20)),
      ),
      child: Text(
        up,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 10.8,
          letterSpacing: 0.4,
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

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            const Icon(Icons.visibility_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: Colors.white,
              ),
            ),
          ],
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

class _HintBox extends StatelessWidget {
  final String text;
  const _HintBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: kTextDark,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _prettyFileName(String? url, String? fileType) {
  final ft = (fileType ?? '').trim();
  if (url == null || url.trim().isEmpty)
    return 'File Materi${ft.isEmpty ? '' : '.$ft'}';

  try {
    final uri = Uri.parse(url);
    // Firebase download URL kadang nggak punya nama asli yang enak → fallback aja
    final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (last.isEmpty) return 'File Materi${ft.isEmpty ? '' : '.$ft'}';
    return 'File Materi${ft.isEmpty ? '' : '.$ft'}';
  } catch (_) {
    return 'File Materi${ft.isEmpty ? '' : '.$ft'}';
  }
}

// ======================================================================
// EMPTY STATE PREMIUM
// ======================================================================
class MateriEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const MateriEmptyState({super.key, required this.onRefresh});

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
              Icons.menu_book_outlined,
              size: 48,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: s16),
          Text(
            'Belum ada materi',
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
            'Materi akan muncul setelah dosen mengunggah.',
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

// ======================================================================
// LOADING + ERROR + NO RESULT
// ======================================================================
class _MateriLoading extends StatelessWidget {
  const _MateriLoading();

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

class _MateriError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _MateriError({required this.message, required this.onRetry});

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
  final VoidCallback onReset;
  const _NoResultState({required this.onReset});

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
            'Materi tidak ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah kata kunci atau reset filter.',
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
