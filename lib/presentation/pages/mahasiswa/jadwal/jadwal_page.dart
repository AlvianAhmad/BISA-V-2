// lib/presentation/pages/mahasiswa/jadwal/jadwal_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

// ===================== THEME (samakan dengan MateriPage) =====================
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

enum JadwalFilter {
  semua,
  hariIni,
  dosenAda,
}

class JadwalPage
    extends
        StatefulWidget {
  final String kelasNama; // ✅ langsung nama kelas
  const JadwalPage({
    super.key,
    required this.kelasNama,
  });

  @override
  State<
    JadwalPage
  >
  createState() => _JadwalPageState();
}

class _JadwalPageState
    extends
        State<
          JadwalPage
        > {
  final TextEditingController _search = TextEditingController();
  JadwalFilter _filter = JadwalFilter.semua;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ============ helper ============
  String _todayIndo() {
    // tanpa intl biar ringan
    final w = DateTime.now().weekday; // 1..7 (Mon..Sun)
    switch (w) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  List<
    QueryDocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  _applyUiFilter(
    List<
      QueryDocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >
    list,
  ) {
    final q = _search.text.trim().toLowerCase();
    final today = _todayIndo().toLowerCase();

    Iterable<
      QueryDocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >
    out = list;

    // chips
    if (_filter ==
        JadwalFilter.hariIni) {
      out = out.where(
        (
          doc,
        ) {
          final d = doc.data();
          final hari =
              (d['hari'] ??
                      '')
                  .toString()
                  .toLowerCase();
          return hari ==
              today;
        },
      );
    } else if (_filter ==
        JadwalFilter.dosenAda) {
      out = out.where(
        (
          doc,
        ) {
          final d = doc.data();
          final dosen =
              (d['dosen'] ??
                      '')
                  .toString()
                  .trim();
          return dosen.isNotEmpty;
        },
      );
    }

    // search (UI-only)
    if (q.isNotEmpty) {
      out = out.where(
        (
          doc,
        ) {
          final d = doc.data();
          final mataKuliah =
              (d['mataKuliah'] ??
                      '')
                  .toString();
          final hari =
              (d['hari'] ??
                      '')
                  .toString();
          final jam =
              (d['jam'] ??
                      '')
                  .toString();
          final dosen =
              (d['dosen'] ??
                      '')
                  .toString();
          final all = '$mataKuliah $hari $jam $dosen'.toLowerCase();
          return all.contains(
            q,
          );
        },
      );
    }

    return out.toList();
  }

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
          'Jadwal',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body:
          StreamBuilder<
            QuerySnapshot<
              Map<
                String,
                dynamic
              >
            >
          >(
            stream: vm.jadwalByKelasNama(
              widget.kelasNama,
            ),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _JadwalLoading();
                  }

                  if (snapshot.hasError) {
                    return _JadwalError(
                      message: 'Error jadwal: ${snapshot.error}',
                      onRetry: () => setState(
                        () {},
                      ),
                    );
                  }

                  final rawList =
                      snapshot.data?.docs ??
                      const [];
                  final uiList = _applyUiFilter(
                    rawList,
                  );

                  return RefreshIndicator(
                    onRefresh: () async => setState(
                      () {},
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        s16,
                        s16,
                        s16,
                        24,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        // ===================== HEADER =====================
                        JadwalHeader(
                          kelasNama: widget.kelasNama,
                          total: rawList.length,
                        ),
                        const SizedBox(
                          height: s16,
                        ),

                        // ===================== SEARCH BAR =====================
                        JadwalSearchBar(
                          controller: _search,
                          onChanged:
                              (
                                _,
                              ) => setState(
                                () {},
                              ),
                          onClear: () {
                            _search.clear();
                            setState(
                              () {},
                            );
                          },
                        ),
                        const SizedBox(
                          height: s12,
                        ),

                        // ===================== FILTER CHIPS =====================
                        _JadwalFilterChips(
                          value: _filter,
                          onChanged:
                              (
                                v,
                              ) => setState(
                                () => _filter = v,
                              ),
                        ),
                        const SizedBox(
                          height: s16,
                        ),

                        // ===================== EMPTY/NO RESULT =====================
                        if (rawList.isEmpty)
                          JadwalEmptyState(
                            onRefresh: () => setState(
                              () {},
                            ),
                          )
                        else if (uiList.isEmpty)
                          _NoResultState(
                            onReset: () {
                              _search.clear();
                              setState(
                                () => _filter = JadwalFilter.semua,
                              );
                            },
                          )
                        else
                          ...List.generate(
                            uiList.length,
                            (
                              index,
                            ) {
                              final d = uiList[index].data();

                              final mataKuliah =
                                  (d['mataKuliah'] ??
                                          '-')
                                      .toString();
                              final hari =
                                  (d['hari'] ??
                                          '-')
                                      .toString();
                              final jam =
                                  (d['jam'] ??
                                          '-')
                                      .toString();
                              final dosen =
                                  (d['dosen'] ??
                                          '')
                                      .toString();

                              // optional (kalau nanti kamu punya field ini, auto kepakai)
                              final ruang =
                                  (d['ruang'] ??
                                          '')
                                      .toString();

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: s12,
                                ),
                                child: JadwalCardModern(
                                  index: index,
                                  mataKuliah: mataKuliah,
                                  hari: hari,
                                  jam: jam,
                                  dosen: dosen,
                                  ruang: ruang,
                                  onTap: () {
                                    // TODO: detail jadwal (opsional)
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
          ),
    );
  }
}

// ======================================================================
// HEADER (samakan vibe MateriHeader)
// ======================================================================
class JadwalHeader
    extends
        StatelessWidget {
  final String kelasNama;
  final int total;

  const JadwalHeader({
    super.key,
    required this.kelasNama,
    required this.total,
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(
                0.12,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons.event_available_rounded,
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
                  'Jadwal Perkuliahan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$total jadwal tersedia • $kelasNama',
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
          const Icon(
            Icons.auto_awesome_rounded,
            color: kPrimary,
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// SEARCH BAR (copy dari MateriSearchBar, beda hint)
// ======================================================================
class JadwalSearchBar
    extends
        StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<
    String
  >
  onChanged;
  final VoidCallback onClear;

  const JadwalSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<
    JadwalSearchBar
  >
  createState() => _JadwalSearchBarState();
}

class _JadwalSearchBarState
    extends
        State<
          JadwalSearchBar
        > {
  bool _focus = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 180,
      ),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: s12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: _focus
              ? kPrimary.withOpacity(
                  0.35,
                )
              : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              _focus
                  ? 0.07
                  : 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Focus(
        onFocusChange:
            (
              v,
            ) => setState(
              () => _focus = v,
            ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: _focus
                  ? kPrimary
                  : kMuted,
            ),
            const SizedBox(
              width: s8,
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari jadwal (matkul/dosen/hari)...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: kMuted.withOpacity(
                      0.9,
                    ),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: widget.controller.text.trim().isEmpty
                  ? 0.0
                  : 1.0,
              duration: const Duration(
                milliseconds: 160,
              ),
              child: IconButton(
                tooltip: 'Hapus',
                onPressed: widget.controller.text.trim().isEmpty
                    ? null
                    : widget.onClear,
                icon: const Icon(
                  Icons.close_rounded,
                ),
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
// FILTER CHIPS (jadwal)
// ======================================================================
class _JadwalFilterChips
    extends
        StatelessWidget {
  final JadwalFilter value;
  final ValueChanged<
    JadwalFilter
  >
  onChanged;

  const _JadwalFilterChips({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Wrap(
      spacing: s8,
      runSpacing: s8,
      children: [
        _chip(
          label: 'Semua',
          icon: Icons.apps_rounded,
          selected:
              value ==
              JadwalFilter.semua,
          onTap: () => onChanged(
            JadwalFilter.semua,
          ),
        ),
        _chip(
          label: 'Hari ini',
          icon: Icons.today_rounded,
          selected:
              value ==
              JadwalFilter.hariIni,
          onTap: () => onChanged(
            JadwalFilter.hariIni,
          ),
        ),
        _chip(
          label: 'Ada dosen',
          icon: Icons.person_rounded,
          selected:
              value ==
              JadwalFilter.dosenAda,
          onTap: () => onChanged(
            JadwalFilter.dosenAda,
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        999,
      ),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? kPrimary.withOpacity(
                  0.12,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(
            999,
          ),
          border: Border.all(
            color: selected
                ? kPrimary.withOpacity(
                    0.35,
                  )
                : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                selected
                    ? 0.06
                    : 0.03,
              ),
              blurRadius: 14,
              offset: const Offset(
                0,
                8,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? kPrimary
                  : kMuted,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected
                    ? kPrimary
                    : kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// CARD MODERN (mirip MateriCardModern, tapi konten jadwal)
// ======================================================================
class JadwalCardModern
    extends
        StatefulWidget {
  final int index;
  final String mataKuliah;
  final String hari;
  final String jam;
  final String dosen;
  final String ruang;
  final VoidCallback onTap;

  const JadwalCardModern({
    super.key,
    required this.index,
    required this.mataKuliah,
    required this.hari,
    required this.jam,
    required this.dosen,
    required this.ruang,
    required this.onTap,
  });

  @override
  State<
    JadwalCardModern
  >
  createState() => _JadwalCardModernState();
}

class _JadwalCardModernState
    extends
        State<
          JadwalCardModern
        > {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final radius = BorderRadius.circular(
      20,
    );

    final subtitleLines =
        <
          String
        >[
          '${widget.hari} • ${widget.jam}',
          if (widget.ruang.trim().isNotEmpty) 'Ruang: ${widget.ruang}',
          if (widget.dosen.trim().isNotEmpty) 'Dosen: ${widget.dosen}',
        ];

    return AnimatedScale(
      scale: _pressed
          ? 0.985
          : 1.0,
      duration: const Duration(
        milliseconds: 120,
      ),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          onHighlightChanged:
              (
                v,
              ) => setState(
                () => _pressed = v,
              ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
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
              border: Border.all(
                color: Colors.black.withOpacity(
                  0.06,
                ),
              ),
              gradient: LinearGradient(
                colors: [
                  kPrimary.withOpacity(
                    0.06,
                  ),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                s16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading icon (jadwal)
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
                    child: const Icon(
                      Icons.schedule_rounded,
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
                        // title
                        Text(
                          widget.mataKuliah,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: kTextDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),

                        // subtitle multi-line
                        Text(
                          subtitleLines.join(
                            '\n',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.8,
                            color: kMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: kMuted.withOpacity(
                      0.9,
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

// ======================================================================
// EMPTY STATE (premium)
// ======================================================================
class JadwalEmptyState
    extends
        StatelessWidget {
  final VoidCallback onRefresh;
  const JadwalEmptyState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        s24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          22,
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
        border: Border.all(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                28,
              ),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: kPrimary,
            ),
          ),
          const SizedBox(
            height: s16,
          ),
          Text(
            'Belum ada jadwal',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: kTextDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            'Jadwal akan muncul setelah admin/dosen mengisi jadwal perkuliahan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(
            height: s16,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRefresh,
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
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                'Refresh',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
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
class _JadwalLoading
    extends
        StatelessWidget {
  const _JadwalLoading();

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
        _skeleton(
          height: 86,
          radius: 20,
        ),
        const SizedBox(
          height: s16,
        ),
        _skeleton(
          height: 54,
          radius: 18,
        ),
        const SizedBox(
          height: s12,
        ),
        _skeleton(
          height: 44,
          radius: 999,
        ),
        const SizedBox(
          height: s16,
        ),
        ...List.generate(
          5,
          (
            _,
          ) => Padding(
            padding: const EdgeInsets.only(
              bottom: s12,
            ),
            child: _skeleton(
              height: 104,
              radius: 20,
            ),
          ),
        ),
        const SizedBox(
          height: s8,
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Widget _skeleton({
    required double height,
    required double radius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          radius,
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
    );
  }
}

class _JadwalError
    extends
        StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _JadwalError({
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

class _NoResultState
    extends
        StatelessWidget {
  final VoidCallback onReset;
  const _NoResultState({
    required this.onReset,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        s24,
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
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(
                0.10,
              ),
              borderRadius: BorderRadius.circular(
                28,
              ),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: kPrimary,
            ),
          ),
          const SizedBox(
            height: s16,
          ),
          Text(
            'Jadwal tidak ditemukan',
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
            'Coba ubah kata kunci atau reset filter.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kMuted,
            ),
          ),
          const SizedBox(
            height: s16,
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: BorderSide(
                  color: kPrimary.withOpacity(
                    0.35,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.restart_alt_rounded,
              ),
              label: Text(
                'Reset',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
