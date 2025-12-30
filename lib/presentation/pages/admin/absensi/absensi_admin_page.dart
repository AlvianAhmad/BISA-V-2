// ignore_for_file: deprecated_member_use, unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';
import 'tambah_absensi_page.dart';
import 'edit_absensi_page.dart';

// ================== GLOBAL THEME (samakan vibe jadwal) ==================
const Color
kAbsensiPrimary = Color(
  0xFF0E2E72,
);
const Color
kAbsensiPrimary2 = Color(
  0xFF1B3C9E,
);
const Color
kAbsensiBg = Color(
  0xFFF5F6FA,
);
const Color
kAbsensiTextDark = Color(
  0xFF1A2552,
);
const Color
kAbsensiMuted = Color(
  0xFF6F7AA6,
);

class AbsensiPage
    extends
        StatefulWidget {
  const AbsensiPage({
    super.key,
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
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<
    Absensi
  >
  _applySearch(
    List<
      Absensi
    >
    data,
  ) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return data;

    return data.where(
      (
        a,
      ) {
        final judul = a.judul.toLowerCase();
        final kelas = a.kelas.toLowerCase();
        final jm = a.jamMulai.toLowerCase();
        final js = a.jamSelesai.toLowerCase();
        final status = a.aktif
            ? 'aktif'
            : 'nonaktif';

        return judul.contains(
              q,
            ) ||
            kelas.contains(
              q,
            ) ||
            jm.contains(
              q,
            ) ||
            js.contains(
              q,
            ) ||
            status.contains(
              q,
            );
      },
    ).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          AbsensiViewModel
        >();

    return Scaffold(
      backgroundColor: kAbsensiBg,
      appBar: AppBar(
        backgroundColor: kAbsensiPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Sesi Absensi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: SafeArea(
        child:
            StreamBuilder<
              List<
                Absensi
              >
            >(
              stream: vm.absensiStream(),
              builder:
                  (
                    context,
                    snapshot,
                  ) {
                    final all =
                        snapshot.data ??
                        const <
                          Absensi
                        >[];
                    final data = _applySearch(
                      all,
                    );

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _HeroHeader(
                            controller: _search,
                            query: _query,
                            total: all.length,
                            shown: data.length,
                            aktif: all
                                .where(
                                  (
                                    e,
                                  ) => e.aktif,
                                )
                                .length,
                            onChanged:
                                (
                                  v,
                                ) => setState(
                                  () => _query = v,
                                ),
                            onAdd: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      _,
                                    ) => const TambahAbsensiPage(),
                              ),
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            120,
                          ),
                          sliver: _buildContentSliver(
                            context: context,
                            vm: vm,
                            snapshot: snapshot,
                            all: all,
                            data: data,
                          ),
                        ),
                      ],
                    );
                  },
            ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kAbsensiPrimary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  _,
                ) => const TambahAbsensiPage(),
          ),
        ),
        child: const Icon(
          Icons.add_rounded,
        ),
      ),
    );
  }

  SliverList _buildContentSliver({
    required BuildContext context,
    required AbsensiViewModel vm,
    required AsyncSnapshot<
      List<
        Absensi
      >
    >
    snapshot,
    required List<
      Absensi
    >
    all,
    required List<
      Absensi
    >
    data,
  }) {
    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return SliverList(
        delegate: SliverChildListDelegate(
          const [
            SizedBox(
              height: 24,
            ),
            _SkeletonCard(),
            _SkeletonCard(),
            _SkeletonCard(),
          ],
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverList(
        delegate: SliverChildListDelegate(
          const [
            SizedBox(
              height: 24,
            ),
            _ModernInfo(
              icon: Icons.wifi_off_rounded,
              title: 'Gagal memuat data',
              subtitle: 'Cek koneksi atau coba lagi.',
            ),
          ],
        ),
      );
    }

    if (all.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [
            const SizedBox(
              height: 18,
            ),
            _ModernInfo(
              icon: Icons.fact_check_rounded,
              title: 'Belum ada sesi absensi',
              subtitle: 'Tambah sesi pertama kamu biar rapi.',
              actionLabel: 'Tambah Sesi',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => const TambahAbsensiPage(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          const [
            SizedBox(
              height: 18,
            ),
            _ModernInfo(
              icon: Icons.search_off_rounded,
              title: 'Tidak ditemukan',
              subtitle: 'Coba kata kunci lain ya.',
            ),
          ],
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (
          context,
          index,
        ) {
          final a = data[index];
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _AbsensiCardV2(
              absensi: a,
              onMore: () => _openActionsSheet(
                context: context,
                absensi: a,
                vm: vm,
              ),
              onToggle:
                  (
                    v,
                  ) => vm.updateAbsensi(
                    a.copyWith(
                      aktif: v,
                    ),
                  ),
            ),
          );
        },
        childCount: data.length,
      ),
    );
  }

  Future<
    void
  >
  _openActionsSheet({
    required BuildContext context,
    required Absensi absensi,
    required AbsensiViewModel vm,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder:
          (
            _,
          ) {
            return _ActionSheet(
              title: absensi.judul,
              subtitle: '${absensi.kelas} • ${absensi.jamMulai} - ${absensi.jamSelesai}',
              onEdit: () async {
                Navigator.pop(
                  context,
                );

                final ok =
                    await Navigator.push<
                      bool
                    >(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              _,
                            ) => EditAbsensiPage(
                              absensi: absensi,
                            ),
                      ),
                    );

                if (ok ==
                        true &&
                    context.mounted) {
                  _showTopToast(
                    context,
                    message: 'Sesi absensi berhasil diperbarui',
                  );
                }
              },
              onDelete: () async {
                Navigator.pop(
                  context,
                );

                final ok = await _confirmDelete(
                  context,
                  absensi.judul,
                );

                if (ok ==
                    true) {
                  await vm.hapusAbsensi(
                    absensi.id,
                  );
                  if (context.mounted) {
                    _showTopToast(
                      context,
                      message: 'Sesi absensi berhasil dihapus',
                    );
                  }
                }
              },
            );
          },
    );
  }

  static Future<
    bool?
  >
  _confirmDelete(
    BuildContext context,
    String title,
  ) {
    return showGeneralDialog<
      bool
    >(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(
        0.45,
      ),
      transitionDuration: const Duration(
        milliseconds: 220,
      ),
      pageBuilder:
          (
            context,
            anim1,
            anim2,
          ) => const SizedBox.shrink(),
      transitionBuilder:
          (
            context,
            anim,
            _,
            __,
          ) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SafeArea(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                      false,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX:
                            10 *
                            curved.value,
                        sigmaY:
                            10 *
                            curved.value,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  Center(
                    child: FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale:
                            Tween<
                                  double
                                >(
                                  begin: 0.95,
                                  end: 1.0,
                                )
                                .animate(
                                  curved,
                                ),
                        child: SlideTransition(
                          position:
                              Tween<
                                    Offset
                                  >(
                                    begin: const Offset(
                                      0,
                                      0.03,
                                    ),
                                    end: Offset.zero,
                                  )
                                  .animate(
                                    curved,
                                  ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  22,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          0.22,
                                        ),
                                        blurRadius: 34,
                                        offset: const Offset(
                                          0,
                                          18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(
                                            0.08,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.14,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  14,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            const Expanded(
                                              child: Text(
                                                'Hapus Sesi?',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: kAbsensiTextDark,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(
                                                999,
                                              ),
                                              onTap: () => Navigator.pop(
                                                context,
                                                false,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(
                                                  6,
                                                ),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  color: kAbsensiMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          14,
                                          16,
                                          2,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kamu yakin ingin menghapus sesi absensi ini?',
                                              style: TextStyle(
                                                color: kAbsensiMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFF7F8FD,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  14,
                                                ),
                                                border: Border.all(
                                                  color: Colors.black.withOpacity(
                                                    0.06,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.fact_check_rounded,
                                                    size: 18,
                                                    color: kAbsensiMuted,
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      title,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: kAbsensiTextDark,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            const Text(
                                              'Tindakan ini tidak dapat dibatalkan.',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 14,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: kAbsensiTextDark,
                                                  side: BorderSide(
                                                    color: Colors.black.withOpacity(
                                                      0.12,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  void _showTopToast(
    BuildContext context, {
    required String message,
    Color bgColor = const Color(
      0xFF22C55E,
    ),
    IconData icon = Icons.check_circle_rounded,
  }) {
    final overlay = Overlay.of(
      context,
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (
            _,
          ) {
            final top =
                MediaQuery.of(
                  context,
                ).padding.top +
                12;

            return Positioned(
              top: top,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child:
                    TweenAnimationBuilder<
                      double
                    >(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      curve: Curves.easeOutCubic,
                      tween: Tween(
                        begin: 0.0,
                        end: 1.0,
                      ),
                      builder:
                          (
                            context,
                            t,
                            child,
                          ) {
                            return Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  (1 -
                                          t) *
                                      -14,
                                ),
                                child: child,
                              ),
                            );
                          },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(
                            18,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            InkWell(
                              onTap: () => entry.remove(),
                              borderRadius: BorderRadius.circular(
                                999,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(
                                  6,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            );
          },
    );

    overlay.insert(
      entry,
    );

    Future.delayed(
      const Duration(
        seconds: 2,
      ),
      () {
        try {
          entry.remove();
        } catch (
          _
        ) {}
      },
    );
  }
}

// ================== HERO HEADER ==================

class _HeroHeader
    extends
        StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int total;
  final int shown;
  final int aktif;
  final ValueChanged<
    String
  >
  onChanged;
  final VoidCallback onAdd;

  const _HeroHeader({
    required this.controller,
    required this.query,
    required this.total,
    required this.shown,
    required this.aktif,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24,
      ),
      decoration: const BoxDecoration(
        color: kAbsensiPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Sesi Absensi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            'Kelola sesi absensi dan status aktif/nonaktif',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 14,
          ),

          _GlassSearch(
            controller: controller,
            onChanged: onChanged,
          ),
          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Total',
                  value: '$total',
                  icon: Icons.list_alt_rounded,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _StatPill(
                  label: 'Aktif',
                  value: '$aktif',
                  icon: Icons.toggle_on_rounded,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _StatPill(
                  label: 'Nonaktif',
                  value: '${total - aktif}',
                  icon: Icons.toggle_off_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassSearch
    extends
        StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<
    String
  >
  onChanged;

  const _GlassSearch({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.16,
            ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.22,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Colors.white70,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari judul / kelas / jam / status...',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(
                Icons.tune_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill
    extends
        StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.14,
            ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.18,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== CARD V2 (mirip ScheduleCardV2) ==================

class _AbsensiCardV2
    extends
        StatelessWidget {
  final Absensi absensi;
  final VoidCallback onMore;
  final ValueChanged<
    bool
  >
  onToggle;

  const _AbsensiCardV2({
    required this.absensi,
    required this.onMore,
    required this.onToggle,
  });

  Color _accent() {
    return absensi.aktif
        ? const Color(
            0xFF22C55E,
          )
        : const Color(
            0xFFEF4444,
          );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final accent = _accent();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 22,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color: Colors.black.withOpacity(
                  0.05,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        absensi.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w900,
                          color: kAbsensiTextDark,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),

                    InkWell(
                      onTap: onMore,
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          6,
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: kAbsensiMuted.withOpacity(
                            0.9,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.class_rounded,
                      text: absensi.kelas,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.access_time_rounded,
                        text: '${absensi.jamMulai} - ${absensi.jamSelesai}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                // STATUS + TOGGLE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF3F5FB,
                    ),
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        absensi.aktif
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        size: 18,
                        color: absensi.aktif
                            ? const Color(
                                0xFF16A34A,
                              )
                            : kAbsensiMuted,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          absensi.aktif
                              ? 'Status: Aktif'
                              : 'Status: Nonaktif',
                          style: const TextStyle(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w800,
                            color: kAbsensiMuted,
                          ),
                        ),
                      ),
                      Switch(
                        value: absensi.aktif,
                        onChanged: onToggle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ACCENT STRIP
          Positioned(
            left: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(
                  999,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip
    extends
        StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF7F8FD,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.05,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: kAbsensiMuted,
          ),
          const SizedBox(
            width: 6,
          ),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kAbsensiTextDark,
                fontWeight: FontWeight.w800,
                fontSize: 12.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== ACTION SHEET ==================

class _ActionSheet
    extends
        StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionSheet({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        0,
        14,
        14,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          22,
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.8,
                        color: kAbsensiTextDark,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kAbsensiMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                ),
                title: const Text(
                  'Edit',
                ),
                onTap: onEdit,
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onTap: onDelete,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== EMPTY / INFO ==================

class _ModernInfo
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ModernInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            22,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.06,
              ),
              blurRadius: 20,
              offset: const Offset(
                0,
                10,
              ),
            ),
          ],
          border: Border.all(
            color: Colors.black.withOpacity(
              0.05,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kAbsensiPrimary.withOpacity(
                  0.10,
                ),
                borderRadius: BorderRadius.circular(
                  18,
                ),
              ),
              child: Icon(
                icon,
                color: kAbsensiPrimary,
                size: 28,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: kAbsensiTextDark,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kAbsensiMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel !=
                    null &&
                onAction !=
                    null) ...[
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAbsensiPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================== SKELETON ==================

class _SkeletonCard
    extends
        StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget bar({
      double w = double.infinity,
      double h = 12,
    }) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(
            0.06,
          ),
          borderRadius: BorderRadius.circular(
            999,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Container(
        padding: const EdgeInsets.all(
          14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: Colors.black.withOpacity(
              0.05,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(
              w: 200,
              h: 14,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: bar(
                    h: 12,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: bar(
                    h: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            bar(
              h: 36,
            ),
          ],
        ),
      ),
    );
  }
}
