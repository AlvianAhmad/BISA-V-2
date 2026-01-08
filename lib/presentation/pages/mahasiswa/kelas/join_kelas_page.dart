// lib/presentation/pages/mahasiswa/kelas/join_kelas_page.dart
// ignore_for_file: unused_element, deprecated_member_use, non_constant_identifier_names, duplicate_ignore

import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bisa/presentation/viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

class JoinKelasPage
    extends
        StatefulWidget {
  const JoinKelasPage({
    super.key,
  });

  @override
  State<
    JoinKelasPage
  >
  createState() => _JoinKelasPageState();
}

class _JoinKelasPageState
    extends
        State<
          JoinKelasPage
        > {
  static const Color _bg = Color(
    0xFFF5F6FA,
  );
  static const Color _textDark = Color(
    0xFF1A2552,
  );
  static const Color _muted = Color(
    0xFF6F7AA6,
  );

  final TextEditingController _search = TextEditingController();

  bool _loadingJoin = false;
  OverlayEntry? _toastEntry;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastTimer = null;

    _toastEntry?.remove();
    _toastEntry = null;

    _search.dispose();
    super.dispose();
  }

  // =======================
  // TOP TOAST (copy vibe dari TambahKelasPage)
  // =======================
  void _showTopToast({
    required OverlayState overlay,
    required String message,
    Color bgColor = const Color(
      0xFF22C55E,
    ),
    IconData icon = Icons.check_circle_rounded,
  }) {
    // tutup toast sebelumnya
    _toastTimer?.cancel();
    _toastEntry?.remove();

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (
            overlayContext,
          ) {
            final top =
                MediaQuery.of(
                  overlayContext,
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
                            c,
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
                              onTap: () {
                                try {
                                  entry.remove();
                                } catch (
                                  _
                                ) {}
                                if (_toastEntry ==
                                    entry)
                                  _toastEntry = null;
                              },
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

    _toastEntry = entry;
    overlay.insert(
      entry,
    );

    _toastTimer = Timer(
      const Duration(
        seconds: 2,
      ),
      () {
        try {
          entry.remove();
        } catch (
          _
        ) {}
        if (_toastEntry ==
            entry)
          _toastEntry = null;
      },
    );
  }

  void _toast(
    NavigatorState nav,
    String msg, {
    bool error = false,
  }) {
    final overlay = nav.overlay;
    if (overlay ==
        null)
      return;

    _showTopToast(
      overlay: overlay,
      message: msg,
      bgColor: error
          ? const Color(
              0xFFEF4444,
            )
          : const Color(
              0xFF22C55E,
            ),
      icon: error
          ? Icons.error_rounded
          : Icons.check_circle_rounded,
    );
  }

  // =======================
  // ✅ AMBIL LIST KELAS YANG SUDAH DI-JOIN USER
  // Pilih salah satu opsi query sesuai struktur Firestore kamu.
  // =======================

  /// OPSI A (umum & rapi): users/{uid}/joined_kelas/{kelasId}
  Stream<
    Set<
      String
    >
  >
  _joinedKelasIdsStream_A() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid ==
        null) {
      return const Stream<
        Set<
          String
        >
      >.empty();
    }
    final db = FirebaseFirestore.instance;
    return db
        .collection(
          'users',
        )
        .doc(
          uid,
        )
        .collection(
          'joined_kelas',
        )
        .snapshots()
        .map(
          (
            snap,
          ) => snap.docs
              .map(
                (
                  d,
                ) => d.id,
              )
              .toSet(),
        );
  }

  /// OPSI B: collection global "kelas_join" / "join_kelas" dll
  /// Contoh dokumen punya field: { kelasId: "...", mahasiswaId: uid, ... }
  Stream<
    Set<
      String
    >
  >
  // ignore: non_constant_identifier_names
  _joinedKelasIdsStream_B() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid ==
        null) {
      return const Stream<
        Set<
          String
        >
      >.empty();
    }

    final db = FirebaseFirestore.instance;

    // ✅ ambil dari collection yang benar: kelas_mahasiswa
    return db
        .collection(
          'kelas_mahasiswa',
        )
        .where(
          'mahasiswaId',
          isEqualTo: uid,
        )
        .snapshots()
        .map(
          (
            snap,
          ) {
            final ids =
                <
                  String
                >{};
            for (final doc in snap.docs) {
              final data = doc.data();
              final kelasId =
                  (data['kelasId'] ??
                          '')
                      .toString()
                      .trim();
              if (kelasId.isNotEmpty) {
                ids.add(
                  kelasId,
                );
              }
            }
            return ids;
          },
        );
  }

  // ✅ Default: pakai OPSI B dulu, kalau Firestore kamu pakai struktur A tinggal ganti return-nya.
  Stream<
    Set<
      String
    >
  >
  _joinedKelasIdsStream() {
    return _joinedKelasIdsStream_B();
    // return _joinedKelasIdsStream_A();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final db = FirebaseFirestore.instance;
    final vm = context
        .read<
          MahasiswaViewModel
        >();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          color: _textDark,
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Gabung Kelas',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: const [
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ 2 stream digabung: stream kelas master + stream joined ids
          StreamBuilder<
            QuerySnapshot<
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
                .snapshots(),
            builder:
                (
                  context,
                  kelasSnap,
                ) {
                  if (kelasSnap.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (kelasSnap.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${kelasSnap.error}',
                      ),
                    );
                  }

                  final docs =
                      kelasSnap.data?.docs ??
                      [];

                  // filter kelas master (bukan doc join)
                  final kelasMaster = docs.where(
                    (
                      doc,
                    ) {
                      final d = doc.data();
                      final hasNama =
                          d['nama'] !=
                          null;

                      // ini filter lama kamu, tetap dipakai
                      final isJoinDoc =
                          d['mahasiswaId'] !=
                              null ||
                          d['joinedAt'] !=
                              null ||
                          d['type'] ==
                              'join';

                      return hasNama &&
                          !isJoinDoc;
                    },
                  ).toList();

                  return StreamBuilder<
                    Set<
                      String
                    >
                  >(
                    stream: _joinedKelasIdsStream(),
                    builder:
                        (
                          context,
                          joinedSnap,
                        ) {
                          final joinedIds =
                              joinedSnap.data ??
                              <
                                String
                              >{};

                          // search filter
                          final q = _search.text.trim().toLowerCase();
                          final filtered = q.isEmpty
                              ? kelasMaster
                              : kelasMaster.where(
                                  (
                                    doc,
                                  ) {
                                    final d = doc.data();
                                    final nama =
                                        (d['nama'] ??
                                                '')
                                            .toString()
                                            .toLowerCase();
                                    final jurusan =
                                        (d['jurusan'] ??
                                                '')
                                            .toString()
                                            .toLowerCase();
                                    final kode =
                                        (d['kode'] ??
                                                '')
                                            .toString()
                                            .toLowerCase();
                                    final semester =
                                        (d['semester'] ??
                                                '')
                                            .toString()
                                            .toLowerCase();

                                    return nama.contains(
                                          q,
                                        ) ||
                                        jurusan.contains(
                                          q,
                                        ) ||
                                        kode.contains(
                                          q,
                                        ) ||
                                        semester.contains(
                                          q,
                                        );
                                  },
                                ).toList();

                          // =========================
                          // 🔥 PILIH PERILAKU:
                          // A) tampil tapi kasih label "Sudah diambil" (default)
                          // B) sembunyikan kelas yang sudah diambil
                          // =========================
                          // ✅ ubah ke true kalau mau disembunyikan

                          final finalList = filtered;

                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    2,
                                    16,
                                    14,
                                  ),
                                  child: _SearchBar(
                                    controller: _search,
                                    onChanged:
                                        (
                                          _,
                                        ) => setState(
                                          () {},
                                        ),
                                  ),
                                ),
                              ),

                              if (finalList.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Text(
                                      q.isEmpty
                                          ? ('Belum ada kelas')
                                          : 'Kelas tidak ditemukan',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                              if (finalList.isNotEmpty)
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (
                                      context,
                                      index,
                                    ) {
                                      final doc = finalList[index];
                                      final d = doc.data();

                                      final nama =
                                          (d['nama'] ??
                                                  '-')
                                              .toString();
                                      final jurusan =
                                          (d['jurusan'] ??
                                                  '')
                                              .toString();
                                      final semester =
                                          (d['semester'] ??
                                                  '')
                                              .toString();
                                      final kode =
                                          (d['kode'] ??
                                                  '')
                                              .toString();
                                      final dosen =
                                          (d['dosen'] ??
                                                  'Dosen')
                                              .toString();

                                      final theme = _CardTheme.pick(
                                        nama,
                                        index,
                                      );

                                      final isJoined = joinedIds.contains(
                                        doc.id,
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          14,
                                        ),
                                        child: _KelasModernCard(
                                          title: nama,
                                          kode: kode.isEmpty
                                              ? null
                                              : kode,
                                          jurusan: jurusan.isEmpty
                                              ? null
                                              : jurusan,
                                          semester: semester.isEmpty
                                              ? null
                                              : semester,
                                          dosen: dosen,
                                          theme: theme,
                                          loading: _loadingJoin,
                                          isJoined: isJoined, // ✅ NEW
                                          onJoin: () async {
                                            if (_loadingJoin) return;

                                            final nav = Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            );

                                            if (isJoined) {
                                              _toast(
                                                nav,
                                                'Kelas ini sudah kamu ambil.',
                                                error: true,
                                              );
                                              return;
                                            }

                                            setState(
                                              () => _loadingJoin = true,
                                            );

                                            try {
                                              await vm
                                                  .joinKelasById(
                                                    doc.id,
                                                  )
                                                  .timeout(
                                                    const Duration(
                                                      seconds: 10,
                                                    ),
                                                  );

                                              // ✅ ini yang bikin balik
                                              if (nav.canPop()) {
                                                nav.pop(
                                                  true,
                                                );
                                              }
                                            } on TimeoutException {
                                              _toast(
                                                nav,
                                                'Join kelas timeout. Cek koneksi atau Firestore rules.',
                                                error: true,
                                              );
                                            } catch (
                                              e
                                            ) {
                                              _toast(
                                                nav,
                                                'Gagal join kelas: $e',
                                                error: true,
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(
                                                  () => _loadingJoin = false,
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      );
                                    },
                                    childCount: finalList.length,
                                  ),
                                ),

                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 24,
                                ),
                              ),
                            ],
                          );
                        },
                  );
                },
          ),

          // ✅ Loading overlay sama seperti TambahKelasPage (blur + dark + spinner putih)
          if (_loadingJoin) ...[
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 6,
                    sigmaY: 6,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.25,
                    ),
                  ),
                ),
              ),
            ),
            const Center(
              child: SizedBox(
                height: 34,
                width: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<
                        Color
                      >(
                        Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ======================
/// SEARCH BAR MODERN
/// ======================
class _SearchBar
    extends
        StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<
    String
  >
  onChanged;

  const _SearchBar({
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
          height: 52,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.78,
            ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: const Color(
                0x14000000,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x0F000000,
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
              const Icon(
                Icons.search_rounded,
                color: Color(
                  0xFF6F7AA6,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari kelas...',
                    hintStyle: TextStyle(
                      color: Color(
                        0xFF6F7AA6,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(
                      0xFF1A2552,
                    ),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    controller.clear();
                    onChanged(
                      '',
                    );
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  color: const Color(
                    0xFF6F7AA6,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================
/// CARD KELAS MODERN
/// ======================
class _KelasModernCard
    extends
        StatelessWidget {
  final String title;
  final String? kode;
  final String? jurusan;
  final String? semester;
  final String dosen;
  final _CardTheme theme;

  final bool loading;
  final bool isJoined; // ✅ NEW
  final VoidCallback onJoin;

  const _KelasModernCard({
    required this.title,
    required this.kode,
    required this.jurusan,
    required this.semester,
    required this.dosen,
    required this.theme,
    required this.loading,
    required this.isJoined,
    required this.onJoin,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        26,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 176,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.gradient.first.withOpacity(
                  0.22,
                ),
                blurRadius: 26,
                offset: const Offset(
                  0,
                  18,
                ),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -60,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.12,
                  ),
                  size: 210,
                ),
              ),
              Positioned(
                left: -40,
                bottom: -70,
                child: _SoftCircle(
                  color: Colors.white.withOpacity(
                    0.08,
                  ),
                  size: 240,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(
                          0.10,
                        ),
                        Colors.transparent,
                        Colors.black.withOpacity(
                          0.06,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badge kode
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20.5,
                              height: 1.12,
                            ),
                          ),
                        ),
                        if (kode !=
                                null &&
                            kode!.isNotEmpty) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          _Badge(
                            text: kode!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    if (jurusan !=
                            null &&
                        jurusan!.isNotEmpty)
                      Text(
                        jurusan!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.92,
                          ),
                          fontWeight: FontWeight.w800,
                          fontSize: 13.6,
                        ),
                      )
                    else
                      Text(
                        '-',
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.85,
                          ),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.6,
                        ),
                      ),

                    const SizedBox(
                      height: 6,
                    ),

                    if (semester !=
                            null &&
                        semester!.isNotEmpty)
                      Text(
                        'Semester $semester',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(
                            0.90,
                          ),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.2,
                        ),
                      ),

                    const SizedBox(
                      height: 14,
                    ),

                    // Dosen chip + tombol join
                    Row(
                      children: [
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.person_rounded,
                            text: dosen,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),

                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed:
                                (loading ||
                                    isJoined)
                                ? null
                                : onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(
                                0.18,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(
                                    0.18,
                                  ),
                                ),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              child: loading
                                  ? const SizedBox(
                                      key: ValueKey(
                                        'loading',
                                      ),
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                              Color
                                            >(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      isJoined
                                          ? 'Sudah diambil'
                                          : 'Join',
                                      key: ValueKey(
                                        isJoined
                                            ? 'joined'
                                            : 'join',
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ✅ label kecil biar jelas
                    if (isJoined) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(
                              0.92,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            'Kelas ini sudah kamu ambil',
                            style: TextStyle(
                              color: Colors.white.withOpacity(
                                0.92,
                              ),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.2,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _InfoChip
    extends
        StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
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
            0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white.withOpacity(
              0.92,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.95,
                ),
                fontWeight: FontWeight.w900,
                fontSize: 13.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge
    extends
        StatelessWidget {
  final String text;
  const _Badge({
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
        color: Colors.white.withOpacity(
          0.18,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SoftCircle
    extends
        StatelessWidget {
  final Color color;
  final double size;

  const _SoftCircle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// ======================
/// THEME PICKER
/// ======================
class _CardTheme {
  final List<
    Color
  >
  gradient;
  final String? illustrationAsset;
  final IconData fallbackIcon;

  const _CardTheme({
    required this.gradient,
    required this.illustrationAsset,
    required this.fallbackIcon,
  });

  static _CardTheme pick(
    String nama,
    int index,
  ) {
    final n = nama.toLowerCase();

    if (n.contains(
      'web',
    )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF2D7FF9,
          ),
          Color(
            0xFF0E2E72,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.language_rounded,
      );
    }
    if (n.contains(
          'wira',
        ) ||
        n.contains(
          'usaha',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF2E9E67,
          ),
          Color(
            0xFF167A52,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.trending_up_rounded,
      );
    }
    if (n.contains(
          'literasi',
        ) ||
        n.contains(
          'digital',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFFFF9F2E,
          ),
          Color(
            0xFFF26B3A,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.auto_stories_rounded,
      );
    }
    if (n.contains(
          'jaringan',
        ) ||
        n.contains(
          'komputer',
        )) {
      return const _CardTheme(
        gradient: [
          Color(
            0xFF6A5CFF,
          ),
          Color(
            0xFF1B3C9E,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.dns_rounded,
      );
    }

    const themes = [
      _CardTheme(
        gradient: [
          Color(
            0xFF2D7FF9,
          ),
          Color(
            0xFF0E2E72,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFF2E9E67,
          ),
          Color(
            0xFF167A52,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFFFF9F2E,
          ),
          Color(
            0xFFF26B3A,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
      _CardTheme(
        gradient: [
          Color(
            0xFF6A5CFF,
          ),
          Color(
            0xFF1B3C9E,
          ),
        ],
        illustrationAsset: null,
        fallbackIcon: Icons.menu_book_rounded,
      ),
    ];

    return themes[index %
        themes.length];
  }
}
