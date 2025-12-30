// lib/presentation/pages/admin/materi/materi_admin_page.dart
// ignore_for_file: deprecated_member_use, unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/admin/materi/materi_view_model.dart';
import 'tambah_materi_page.dart';
import 'edit_materi_page.dart';

// ================== GLOBAL THEME (samain vibe Kelas) ==================
const Color
kMateriPrimary = Color(
  0xFF0E2E72,
);
const Color
kMateriPrimary2 = Color(
  0xFF1B3C9E,
);
const Color
kMateriBg = Color(
  0xFFF5F6FA,
);
const Color
kMateriTextDark = Color(
  0xFF1A2552,
);
const Color
kMateriMuted = Color(
  0xFF6F7AA6,
);

class MateriAdminPage
    extends
        StatefulWidget {
  final String kelasId;
  final String kelasNama;

  const MateriAdminPage({
    super.key,
    required this.kelasId,
    required this.kelasNama,
  });

  @override
  State<
    MateriAdminPage
  >
  createState() => _MateriAdminPageState();
}

class _MateriAdminPageState
    extends
        State<
          MateriAdminPage
        > {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  // ✅ untuk TambahMateriPage (required)
  static const List<
    String
  >
  _pertemuanList = [
    'Pertemuan 1',
    'Pertemuan 2',
    'Pertemuan 3',
    'Pertemuan 4',
    'Pertemuan 5',
    'Pertemuan 6',
    'Pertemuan 7',
    'Pertemuan 8',
    'UTS',
    'Pertemuan 9',
    'Pertemuan 10',
    'Pertemuan 11',
    'Pertemuan 12',
    'Pertemuan 13',
    'Pertemuan 14',
    'UAS',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<
    Materi
  >
  _applySearch(
    List<
      Materi
    >
    data,
  ) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return data;

    return data.where(
      (
        m,
      ) {
        final judul = (m.judul).toString().toLowerCase();
        final desk = (m.deskripsi).toString().toLowerCase();
        return judul.contains(
              q,
            ) ||
            desk.contains(
              q,
            );
      },
    ).toList();
  }

  Future<
    void
  >
  _openDetailDialog(
    BuildContext context,
    Materi materi,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (
            _,
          ) {
            return DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.35,
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
                                    color: kMateriPrimary.withOpacity(
                                      0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      14,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    color: kMateriPrimary,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Text(
                                    materi.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                      color: kMateriTextDark,
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
                                      color: kMateriMuted,
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
                                  title: 'Deskripsi Materi',
                                  icon: Icons.description_rounded,
                                  child: Text(
                                    (materi.deskripsi).toString().trim().isEmpty
                                        ? 'Tidak ada deskripsi.'
                                        : materi.deskripsi,
                                    style: const TextStyle(
                                      fontSize: 13.6,
                                      height: 1.35,
                                      color: kMateriTextDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),

                                // Kalau Materi kamu punya field lain (link/file/pertemuan),
                                // tinggal tambahin section di sini tanpa buat file baru.
                                _HintBox(
                                  text: 'Untuk Edit / Hapus, gunakan tombol (⋯) pada kartu materi.',
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
          MateriViewModel
        >();

    return Scaffold(
      backgroundColor: kMateriBg,
      appBar: AppBar(
        backgroundColor: kMateriPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(
            context,
            true,
          ),
        ),
        title: Text(
          'Materi ${widget.kelasNama}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: SafeArea(
        child:
            StreamBuilder<
              List<
                Materi
              >
            >(
              stream: vm.materiStream(
                widget.kelasId,
              ),
              builder:
                  (
                    context,
                    snap,
                  ) {
                    if (snap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snap.hasError) {
                      return const Center(
                        child: _ModernInfo(
                          icon: Icons.error_outline_rounded,
                          title: 'Gagal memuat materi',
                          subtitle: 'Coba cek koneksi / backend.',
                        ),
                      );
                    }

                    final all =
                        snap.data ??
                        [];
                    final data = _applySearch(
                      all,
                    );

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _HeroHeaderMateri(
                            controller: _search,
                            query: _query,
                            total: all.length,
                            shown: data.length,
                            onChanged:
                                (
                                  v,
                                ) => setState(
                                  () => _query = v,
                                ),
                            onAdd: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (
                                        _,
                                      ) => TambahMateriPage(
                                        kelasId: widget.kelasId,
                                        kelasNama: widget.kelasNama,
                                        pertemuanList: _pertemuanList,
                                      ),
                                ),
                              );
                              if (mounted)
                                setState(
                                  () {},
                                );
                            },
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
        backgroundColor: kMateriPrimary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (
                    _,
                  ) => TambahMateriPage(
                    kelasId: widget.kelasId,
                    kelasNama: widget.kelasNama,
                    pertemuanList: _pertemuanList,
                  ),
            ),
          );
          if (mounted)
            setState(
              () {},
            );
        },
        child: const Icon(
          Icons.add_rounded,
        ),
      ),
    );
  }

  SliverList _buildContentSliver({
    required BuildContext context,
    required MateriViewModel vm,
    required List<
      Materi
    >
    all,
    required List<
      Materi
    >
    data,
  }) {
    if (all.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [
            const SizedBox(
              height: 18,
            ),
            _ModernInfo(
              icon: Icons.menu_book_rounded,
              title: 'Belum ada materi',
              subtitle: 'Tambah materi pertama untuk kelas ini.',
              actionLabel: 'Tambah Materi',
              onAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          _,
                        ) => TambahMateriPage(
                          kelasId: widget.kelasId,
                          kelasNama: widget.kelasNama,
                          pertemuanList: _pertemuanList,
                        ),
                  ),
                );
                if (mounted)
                  setState(
                    () {},
                  );
              },
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
          final materi = data[index];

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _MateriCardV2(
              judul: materi.judul,
              deskripsi: materi.deskripsi,
              onOpen: () => _openDetailDialog(
                context,
                materi,
              ), // ✅ BUKAN KE EDIT
              onMore: () => _openActionsSheet(
                context: context,
                materi: materi,
                vm: vm,
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
    required Materi materi,
    required MateriViewModel vm,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (
            _,
          ) {
            return _ActionSheet(
              title: materi.judul,
              subtitle: 'Pilih aksi untuk materi ini',
              onEdit: () async {
                Navigator.pop(
                  context,
                );
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          _,
                        ) => EditMateriPage(
                          materi: materi,
                        ),
                  ),
                );
                if (context.mounted)
                  setState(
                    () {},
                  );
              },
              onDelete: () async {
                Navigator.pop(
                  context,
                );
                final ok = await _confirmDelete(
                  context,
                  materi.judul,
                );
                if (ok ==
                    true) {
                  await vm.hapusMateri(
                    materi.id,
                  );
                  if (context.mounted) {
                    _showTopToast(
                      context,
                      message: 'Materi berhasil dihapus',
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
                                              'Hapus Materi?',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: kMateriTextDark,
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
                                                color: kMateriMuted,
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
                                            'Kamu yakin ingin menghapus materi ini?',
                                            style: TextStyle(
                                              color: kMateriMuted,
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
                                                  Icons.menu_book_rounded,
                                                  size: 18,
                                                  color: kMateriMuted,
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
                                                      color: kMateriTextDark,
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
                                                foregroundColor: kMateriTextDark,
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

// ================== HERO HEADER (MATERI) ==================

class _HeroHeaderMateri
    extends
        StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int total;
  final int shown;
  final ValueChanged<
    String
  >
  onChanged;
  final VoidCallback onAdd;

  const _HeroHeaderMateri({
    required this.controller,
    required this.query,
    required this.total,
    required this.shown,
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
        color: kMateriPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Materi',
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
            'Kelola materi untuk kelas ini',
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
            hint: 'Cari judul / deskripsi materi...',
            onChanged: onChanged,
            onAdd: onAdd,
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
                  label: 'Ditampilkan',
                  value: '$shown',
                  icon: Icons.filter_alt_rounded,
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
  final String hint;
  final ValueChanged<
    String
  >
  onChanged;
  final VoidCallback onAdd;

  const _GlassSearch({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onAdd,
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
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(
                  12,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(
                    6,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                  ),
                ),
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

// ================== CARD (MATERI) ==================

class _MateriCardV2
    extends
        StatelessWidget {
  final String judul;
  final String deskripsi;
  final VoidCallback onOpen; // ✅ sekarang buka detail, bukan edit
  final VoidCallback onMore;

  const _MateriCardV2({
    required this.judul,
    required this.deskripsi,
    required this.onOpen,
    required this.onMore,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final desc = deskripsi.toString().trim();

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
          InkWell(
            onTap: onOpen, // ✅ buka detail
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: Container(
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
                          judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.8,
                            fontWeight: FontWeight.w900,
                            color: kMateriTextDark,
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
                            color: kMateriMuted.withOpacity(
                              0.9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // CHIP ROW (biar kaya gaya kelas)
                  Row(
                    children: const [
                      _MetaChip(
                        icon: Icons.menu_book_rounded,
                        text: 'Materi',
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: _MetaChip(
                          icon: Icons.visibility_rounded,
                          text: 'Tap untuk lihat detail',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ✅ DESKRIPSI (gaya seperti contoh: box + icon + teks)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.description_rounded,
                          size: 18,
                          color: kMateriMuted,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            desc.isEmpty
                                ? 'Belum ada deskripsi materi.'
                                : desc,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w800,
                              color: kMateriMuted,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: kMateriMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                color: kMateriPrimary2,
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
            color: kMateriMuted,
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
                color: kMateriTextDark,
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
                        color: kMateriTextDark,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kMateriMuted,
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
                color: kMateriPrimary.withOpacity(
                  0.10,
                ),
                borderRadius: BorderRadius.circular(
                  18,
                ),
              ),
              child: Icon(
                icon,
                color: kMateriPrimary,
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
                color: kMateriTextDark,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kMateriMuted,
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
                  backgroundColor: kMateriPrimary,
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

// ================== MINI UI COMPONENTS (DETAIL) ==================

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
                color: kMateriPrimary,
                size: 18,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: kMateriTextDark,
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

class _HintBox
    extends
        StatelessWidget {
  final String text;
  const _HintBox({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: kMateriPrimary.withOpacity(
          0.06,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: kMateriPrimary.withOpacity(
            0.12,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: kMateriPrimary,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kMateriTextDark,
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
