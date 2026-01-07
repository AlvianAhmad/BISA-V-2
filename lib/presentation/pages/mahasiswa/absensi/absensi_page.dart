// ========================= absensi_page.dart (STYLE MIRIP TUGAS) =========================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

// ===================== THEME (samakan dengan Tugas/Materi) =====================
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

enum AbsensiFilter {
  semua,
  aktifSaja,
  hariIni,
}

class AbsensiPage
    extends
        StatefulWidget {
  final String kelasNama;
  const AbsensiPage({
    super.key,
    required this.kelasNama,
  });

  @override
  State<
    AbsensiPage
  >
  createState() => _AbsensiPageState();
}

class _AbsensiPageState
    extends
        State<
          AbsensiPage
        > {
  final TextEditingController _search = TextEditingController();
  AbsensiFilter _filter = AbsensiFilter.semua;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ---------- Helpers deadline/tanggal ----------
  DateTime _extractTanggal(
    Map<
      String,
      dynamic
    >
    data,
  ) {
    final raw = data['tanggal'];
    if (raw
        is Timestamp)
      return raw.toDate();
    if (raw
        is DateTime)
      return raw;
    if (raw
        is int)
      return DateTime.fromMillisecondsSinceEpoch(
        raw,
      );
    if (raw
        is String)
      return DateTime.tryParse(
            raw,
          ) ??
          DateTime.fromMillisecondsSinceEpoch(
            0,
          );
    return DateTime.fromMillisecondsSinceEpoch(
      0,
    );
  }

  bool
  _isToday(
    DateTime d,
  ) => DateUtils.isSameDay(
    d,
    DateTime.now(),
  );

  String _fmtTanggal(
    DateTime d,
  ) {
    // butuh intl + locale id_ID (kalau error locale, lihat catatan di bawah)
    return DateFormat(
      'dd MMM yyyy • HH:mm',
      'id_ID',
    ).format(
      d.toLocal(),
    );
  }

  // ---------- Filter + Search ----------
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
    docs,
  ) {
    final q = _search.text.trim().toLowerCase();
    Iterable<
      QueryDocumentSnapshot<
        Map<
          String,
          dynamic
        >
      >
    >
    out = docs;

    if (_filter ==
        AbsensiFilter.aktifSaja) {
      out = out.where(
        (
          d,
        ) =>
            (d.data()['aktif'] ??
                false) ==
            true,
      );
    } else if (_filter ==
        AbsensiFilter.hariIni) {
      out = out.where(
        (
          d,
        ) {
          final t = _extractTanggal(
            d.data(),
          );
          return _isToday(
            t,
          );
        },
      );
    }

    if (q.isNotEmpty) {
      out = out.where(
        (
          d,
        ) {
          final data = d.data();
          final judul =
              (data['judul'] ??
                      '')
                  .toString();
          final jamMulai =
              (data['jamMulai'] ??
                      '')
                  .toString();
          final jamSelesai =
              (data['jamSelesai'] ??
                      '')
                  .toString();
          final s = '$judul $jamMulai $jamSelesai'.toLowerCase();
          return s.contains(
            q,
          );
        },
      );
    }

    return out.toList();
  }

  // ---------- Bottomsheet Detail ----------
  Future<
    void
  >
  _openAbsensiDetail({
    required BuildContext context,
    required String absensiId,
    required String judul,
    required bool aktif,
    required DateTime tanggal,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    final sudah = await context
        .read<
          MahasiswaViewModel
        >()
        .sudahAbsen(
          absensiId,
        );

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (
            _,
          ) {
            return DraggableScrollableSheet(
              initialChildSize: 0.70,
              minChildSize: 0.40,
              maxChildSize: 0.92,
              builder:
                  (
                    context,
                    scrollController,
                  ) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            22,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                999,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(
                                      0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      14,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.how_to_reg_rounded,
                                    color: kPrimary,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
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
                                  borderRadius: BorderRadius.circular(
                                    999,
                                  ),
                                  onTap: () => Navigator.pop(
                                    context,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(
                                      6,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: kMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),
                          const Divider(
                            height: 1,
                          ),

                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                16,
                              ),
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
                                const SizedBox(
                                  height: 12,
                                ),

                                _DetailSection(
                                  title: 'Waktu',
                                  icon: Icons.schedule_rounded,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fmtTanggal(
                                          tanggal,
                                        ),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.6,
                                          height: 1.35,
                                          color: kTextDark,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        'Jam: $jamMulai - $jamSelesai',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.0,
                                          height: 1.35,
                                          color: kMuted,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),

                                _DetailSection(
                                  title: 'Status',
                                  icon: Icons.verified_rounded,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _StatusBadge(
                                        label: aktif
                                            ? 'AKTIF'
                                            : 'NONAKTIF',
                                        tone: aktif
                                            ? _Tone.good
                                            : _Tone.neutral,
                                        icon: aktif
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.block_rounded,
                                      ),
                                      _StatusBadge(
                                        label: sudah
                                            ? 'SUDAH HADIR'
                                            : 'BELUM HADIR',
                                        tone: sudah
                                            ? _Tone.good
                                            : _Tone.warning,
                                        icon: sudah
                                            ? Icons.check_circle_rounded
                                            : Icons.hourglass_bottom_rounded,
                                      ),
                                      if (_isToday(
                                        tanggal,
                                      ))
                                        _StatusBadge(
                                          label: 'HARI INI',
                                          tone: _Tone.info,
                                          icon: Icons.today_rounded,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),

                                _DetailSection(
                                  title: 'Aksi',
                                  icon: Icons.how_to_reg_rounded,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          (!aktif ||
                                              sudah)
                                          ? null
                                          : () async {
                                              Navigator.pop(
                                                context,
                                              );
                                              await context
                                                  .read<
                                                    MahasiswaViewModel
                                                  >()
                                                  .absen(
                                                    absensiId,
                                                  );
                                              if (mounted)
                                                setState(
                                                  () {},
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
                                      icon: const Icon(
                                        Icons.how_to_reg_rounded,
                                      ),
                                      label: Text(
                                        sudah
                                            ? 'Sudah Hadir'
                                            : 'Hadir Sekarang',
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
          'Absensi',
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
            stream: vm.absensiByKelasNama(
              widget.kelasNama,
            ),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _AbsensiLoading();
                  }

                  if (snapshot.hasError) {
                    return _AbsensiError(
                      message: '${snapshot.error}',
                      onRetry: () => setState(
                        () {},
                      ),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return _EmptyState(
                      onRefresh: () => setState(
                        () {},
                      ),
                    );
                  }

                  // SORT terbaru dulu (client)
                  final raw = snapshot.data!.docs.toList()
                    ..sort(
                      (
                        a,
                        b,
                      ) {
                        final da = _extractTanggal(
                          a.data(),
                        );
                        final db = _extractTanggal(
                          b.data(),
                        );
                        return db.compareTo(
                          da,
                        );
                      },
                    );

                  final uiDocs = _applyUiFilter(
                    raw,
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
                        AbsensiHeader(
                          total: raw.length,
                          kelasNama: widget.kelasNama,
                        ),
                        const SizedBox(
                          height: s16,
                        ),

                        _SearchBar(
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
                          hint: 'Cari absensi...',
                        ),
                        const SizedBox(
                          height: s12,
                        ),

                        _FilterChips(
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

                        if (uiDocs.isEmpty)
                          _NoResultState(
                            title:
                                _filter ==
                                    AbsensiFilter.hariIni
                                ? 'Tidak ada absensi hari ini'
                                : 'Absensi tidak ditemukan',
                            subtitle:
                                _filter ==
                                    AbsensiFilter.hariIni
                                ? 'Coba ubah filter ke "Semua" atau "Aktif".'
                                : 'Coba ubah kata kunci atau reset filter.',
                            onReset: () {
                              _search.clear();
                              setState(
                                () => _filter = AbsensiFilter.semua,
                              );
                            },
                          )
                        else
                          ...List.generate(
                            uiDocs.length,
                            (
                              index,
                            ) {
                              final doc = uiDocs[index];
                              final d = doc.data();

                              final judul =
                                  (d['judul'] ??
                                          '-')
                                      .toString();
                              final aktif =
                                  (d['aktif'] ??
                                      false) ==
                                  true;
                              final tanggal = _extractTanggal(
                                d,
                              );
                              final jamMulai =
                                  (d['jamMulai'] ??
                                          '')
                                      .toString();
                              final jamSelesai =
                                  (d['jamSelesai'] ??
                                          '')
                                      .toString();

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: s12,
                                ),
                                child: _AbsensiCardModern(
                                  title: judul.isEmpty
                                      ? '-'
                                      : judul,
                                  subtitle: '${_fmtTanggal(tanggal)} • $jamMulai - $jamSelesai',
                                  aktif: aktif,
                                  isToday: _isToday(
                                    tanggal,
                                  ),
                                  sudahFuture: vm.sudahAbsen(
                                    doc.id,
                                  ),
                                  onTap: () => _openAbsensiDetail(
                                    context: context,
                                    absensiId: doc.id,
                                    judul: judul,
                                    aktif: aktif,
                                    tanggal: tanggal,
                                    jamMulai: jamMulai,
                                    jamSelesai: jamSelesai,
                                  ),
                                  onPrimaryAction: () async {
                                    await vm.absen(
                                      doc.id,
                                    );
                                    if (mounted)
                                      setState(
                                        () {},
                                      );
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
// HEADER (mirip TugasHeader)
// ======================================================================
class AbsensiHeader
    extends
        StatelessWidget {
  final int total;
  final String kelasNama;
  const AbsensiHeader({
    super.key,
    required this.total,
    required this.kelasNama,
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
              Icons.how_to_reg_rounded,
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
                  'Absensi Kelas',
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
                  '$total sesi • $kelasNama',
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
// SEARCH BAR (reusable)
// ======================================================================
class _SearchBar
    extends
        StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<
    String
  >
  onChanged;
  final VoidCallback onClear;
  final String hint;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hint,
  });

  @override
  State<
    _SearchBar
  >
  createState() => _SearchBarState();
}

class _SearchBarState
    extends
        State<
          _SearchBar
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
                  hintText: widget.hint,
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
// FILTER CHIPS
// ======================================================================
class _FilterChips
    extends
        StatelessWidget {
  final AbsensiFilter value;
  final ValueChanged<
    AbsensiFilter
  >
  onChanged;

  const _FilterChips({
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
          selected:
              value ==
              AbsensiFilter.semua,
          onTap: () => onChanged(
            AbsensiFilter.semua,
          ),
          icon: Icons.apps_rounded,
        ),
        _chip(
          label: 'Aktif',
          selected:
              value ==
              AbsensiFilter.aktifSaja,
          onTap: () => onChanged(
            AbsensiFilter.aktifSaja,
          ),
          icon: Icons.radio_button_checked_rounded,
        ),
        _chip(
          label: 'Hari Ini',
          selected:
              value ==
              AbsensiFilter.hariIni,
          onTap: () => onChanged(
            AbsensiFilter.hariIni,
          ),
          icon: Icons.today_rounded,
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
// CARD MODERN + STATUS HADIR
// ======================================================================
class _AbsensiCardModern
    extends
        StatefulWidget {
  final String title;
  final String subtitle;
  final bool aktif;
  final bool isToday;
  final Future<
    bool
  >
  sudahFuture;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;

  const _AbsensiCardModern({
    required this.title,
    required this.subtitle,
    required this.aktif,
    required this.isToday,
    required this.sudahFuture,
    required this.onTap,
    required this.onPrimaryAction,
  });

  @override
  State<
    _AbsensiCardModern
  >
  createState() => _AbsensiCardModernState();
}

class _AbsensiCardModernState
    extends
        State<
          _AbsensiCardModern
        > {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final radius = BorderRadius.circular(
      20,
    );

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
                      Icons.how_to_reg_rounded,
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
                        // Title + badge (aktif/hari ini)
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
                            const SizedBox(
                              width: 8,
                            ),
                            _Badge(
                              label: widget.aktif
                                  ? 'AKTIF'
                                  : 'NONAKTIF',
                              tone: widget.aktif
                                  ? _Tone.good
                                  : _Tone.neutral,
                            ),
                            if (widget.isToday) ...[
                              const SizedBox(
                                width: 8,
                              ),
                              const _Badge(
                                label: 'HARI INI',
                                tone: _Tone.info,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),

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
                        const SizedBox(
                          height: s12,
                        ),

                        // Status hadir + action
                        FutureBuilder<
                          bool
                        >(
                          future: widget.sudahFuture,
                          builder:
                              (
                                context,
                                s,
                              ) {
                                final loading =
                                    s.connectionState ==
                                    ConnectionState.waiting;
                                final sudah =
                                    s.data ??
                                    false;

                                return Row(
                                  children: [
                                    _MiniBadge(
                                      label: loading
                                          ? 'Memuat...'
                                          : (sudah
                                                ? 'Sudah Hadir'
                                                : 'Belum Hadir'),
                                      icon: loading
                                          ? Icons.hourglass_bottom_rounded
                                          : (sudah
                                                ? Icons.check_circle_rounded
                                                : Icons.pending_actions_rounded),
                                    ),
                                    const Spacer(),
                                    _PrimaryButton(
                                      label: sudah
                                          ? 'Hadir'
                                          : 'Hadir',
                                      onPressed:
                                          (!widget.aktif ||
                                              sudah ||
                                              loading)
                                          ? null
                                          : widget.onPrimaryAction,
                                      icon: Icons.how_to_reg_rounded,
                                    ),
                                  ],
                                );
                              },
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

// ======================================================================
// BADGES / BUTTON
// ======================================================================
enum _Tone {
  info,
  good,
  warning,
  neutral,
}

class _Badge
    extends
        StatelessWidget {
  final String label;
  final _Tone tone;
  const _Badge({
    required this.label,
    this.tone = _Tone.info,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Color c = kPrimary;
    if (tone ==
        _Tone.good)
      c = const Color(
        0xFF22C55E,
      );
    if (tone ==
        _Tone.warning)
      c = const Color(
        0xFFF59E0B,
      );
    if (tone ==
        _Tone.neutral)
      c = const Color(
        0xFF64748B,
      );

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
          fontWeight: FontWeight.w800,
          fontSize: 10.8,
          letterSpacing: 0.4,
          color: c,
        ),
      ),
    );
  }
}

class _StatusBadge
    extends
        StatelessWidget {
  final String label;
  final IconData icon;
  final _Tone tone;

  const _StatusBadge({
    required this.label,
    required this.icon,
    this.tone = _Tone.info,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Color c = kPrimary;
    if (tone ==
        _Tone.good)
      c = const Color(
        0xFF22C55E,
      );
    if (tone ==
        _Tone.warning)
      c = const Color(
        0xFFF59E0B,
      );
    if (tone ==
        _Tone.neutral)
      c = const Color(
        0xFF64748B,
      );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: c,
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: c,
            ),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          999,
        ),
        border: Border.all(
          color: Colors.black12,
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

class _PrimaryButton
    extends
        StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final disabled =
        onPressed ==
        null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(
        14,
      ),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: disabled
              ? kPrimary.withOpacity(
                  0.35,
                )
              : kPrimary,
          borderRadius: BorderRadius.circular(
            14,
          ),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: kPrimary.withOpacity(
                      0.25,
                    ),
                    blurRadius: 14,
                    offset: const Offset(
                      0,
                      10,
                    ),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(
              width: 8,
            ),
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
    );
  }
}

// ======================================================================
// DETAIL SECTION (reuse style tugas)
// ======================================================================
class _DetailSection
    extends
        StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSection({
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
        12,
        12,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF7F8FD,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: kPrimary,
                size: 18,
              ),
              const SizedBox(
                width: 8,
              ),
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
          const SizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }
}

// ======================================================================
// EMPTY / LOADING / ERROR / NO RESULT (premium style)
// ======================================================================
class _EmptyState
    extends
        StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({
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
              Icons.how_to_reg_outlined,
              size: 48,
              color: kPrimary,
            ),
          ),
          const SizedBox(
            height: s16,
          ),
          Text(
            'Belum ada absensi',
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
            'Absensi akan muncul setelah dosen menambahkan.',
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

class _AbsensiLoading
    extends
        StatelessWidget {
  const _AbsensiLoading();

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
          height: 86,
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
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              18,
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
        ...List.generate(
          4,
          (
            _,
          ) => Padding(
            padding: const EdgeInsets.only(
              bottom: s12,
            ),
            child: Container(
              height: 112,
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
}

class _AbsensiError
    extends
        StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _AbsensiError({
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
  final String title;
  final String subtitle;
  final VoidCallback onReset;

  const _NoResultState({
    required this.title,
    required this.subtitle,
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
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: kTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            subtitle,
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
