// lib/presentation/pages/admin/kelas/tambah_kelas_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class TambahKelasPage
    extends
        StatefulWidget {
  const TambahKelasPage({
    super.key,
  });

  @override
  State<
    TambahKelasPage
  >
  createState() => _TambahKelasPageState();
}

class _TambahKelasPageState
    extends
        State<
          TambahKelasPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();

  final nama = TextEditingController();
  final jurusan = TextEditingController();
  final semester = TextEditingController();

  bool _saving = false; // ✅ PENTING: jangan bool? (biar gak null)

  // ====== MODERN THEME (samain absensi/jadwal) ======
  static const Color _bg = Color(
    0xFFF6F7FB,
  );
  // ignore: unused_field
  static const Color _primary = Color(
    0xFF1B3C9E,
  );
  static const Color _primary2 = Color(
    0xFF0E2E72,
  );

  @override
  void dispose() {
    nama.dispose();
    jurusan.dispose();
    semester.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _save(
    KelasViewModel vm,
  ) async {
    if (_saving) return;

    final valid =
        _formKey.currentState?.validate() ??
        false;
    if (!valid) return;

    setState(
      () => _saving = true,
    );

    try {
      await vm.tambahKelas(
        Kelas(
          id: '',
          nama: nama.text.trim(),
          jurusan: jurusan.text.trim(),
          semester: semester.text.trim(),
        ),
      );

      if (!mounted) return;
      _showTopToast(
        context,
        message: 'Kelas berhasil ditambahkan',
      );
      Navigator.pop(
        context,
        true,
      );
    } catch (
      _
    ) {
      if (!mounted) return;
      _toast(
        'Gagal menyimpan kelas. Coba lagi.',
      );
      setState(
        () => _saving = false,
      );
    }
  }

  void _toast(
    String msg,
  ) {
    ScaffoldMessenger.of(
      context,
    ).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(
          seconds: 2,
        ),
      ),
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          KelasViewModel
        >();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary2,
        surfaceTintColor: _primary2,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Tambah Kelas',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔵 header biru
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _primary2,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          28,
                        ),
                        bottomRight: Radius.circular(
                          28,
                        ),
                      ),
                    ),
                  ),

                  // 🤍 card overlap
                  Transform.translate(
                    offset: const Offset(
                      0,
                      -120,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16,
                      ),
                      child: _GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 4,
                              ),
                              const _SectionTitle(
                                icon: Icons.class_rounded,
                                title: 'Detail Kelas',
                                caption: 'Lengkapi nama kelas, jurusan, dan semester.',
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              _ModernField(
                                label: 'Nama Kelas',
                                hint: 'Contoh: 23IK-A',
                                controller: nama,
                                icon: Icons.badge_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Jurusan',
                                hint: 'Contoh: Ilmu Komputer',
                                controller: jurusan,
                                icon: Icons.school_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Semester',
                                hint: 'Contoh: 3',
                                controller: semester,
                                icon: Icons.filter_9_plus_rounded,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(
                                height: 18,
                              ),
                              const _DividerSoft(),
                              const SizedBox(
                                height: 16,
                              ),

                              _PreviewKelasCard(
                                nama: nama.text.trim(),
                                jurusan: jurusan.text.trim(),
                                semester: semester.text.trim(),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 2,
                                ),
                                child: _BottomBar(
                                  saving: _saving,
                                  onCancel: _saving
                                      ? null
                                      : () => Navigator.pop(
                                          context,
                                        ),
                                  onSave: _saving
                                      ? null
                                      : () => _save(
                                          vm,
                                        ),
                                  saveText: 'Simpan Kelas',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),

          if (_saving) ...[
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

/// ============================ UI WIDGETS ============================

class _GlassCard
    extends
        StatelessWidget {
  final Widget child;
  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.95,
        ),
        borderRadius: BorderRadius.circular(
          22,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 18,
            offset: const Offset(
              0,
              10,
            ),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(
            0.55,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          20,
        ),
        child: child,
      ),
    );
  }
}

class _SectionTitle
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(
              0xFFEFF2FF,
            ),
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(
              0xFF0E2E72,
            ),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                caption,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(
                    0.55,
                  ),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModernField
    extends
        StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  const _ModernField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.textInputAction,
    this.keyboardType,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(
              0.72,
            ),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(
              0xFFF3F5FF,
            ),
            borderRadius: BorderRadius.circular(
              16,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(
                0.7,
              ),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator:
                (
                  v,
                ) {
                  if (v ==
                          null ||
                      v.trim().isEmpty)
                    return '$label wajib diisi';
                  return null;
                },
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(
                  0.35,
                ),
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                icon,
                color: _primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            onChanged:
                (
                  _,
                ) {
                  (context
                          as Element)
                      .markNeedsBuild(); // biar preview update
                },
          ),
        ),
      ],
    );
  }
}

class _PreviewKelasCard
    extends
        StatelessWidget {
  final String nama;
  final String jurusan;
  final String semester;

  const _PreviewKelasCard({
    required this.nama,
    required this.jurusan,
    required this.semester,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final n = nama.trim();
    final j = jurusan.trim();
    final s = semester.trim();

    final hasAny =
        n.isNotEmpty ||
        j.isNotEmpty ||
        s.isNotEmpty;

    Widget chip(
      IconData icon,
      String text,
    ) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              const Color(
                0xFF1B3C9E,
              ).withOpacity(
                0.08,
              ),
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color:
                const Color(
                  0xFF0E2E72,
                ).withOpacity(
                  0.12,
                ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(
                0xFF0E2E72,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(
                  0.78,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 220,
      ),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          18,
        ),
        color: hasAny
            ? const Color(
                0xFF0E2E72,
              ).withOpacity(
                0.06,
              )
            : Colors.white,
        border: Border.all(
          color: hasAny
              ? const Color(
                  0xFF0E2E72,
                ).withOpacity(
                  0.14,
                )
              : Colors.black.withOpacity(
                  0.06,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ),
              color:
                  const Color(
                    0xFF1B3C9E,
                  ).withOpacity(
                    0.10,
                  ),
            ),
            child: const Icon(
              Icons.visibility_rounded,
              color: Color(
                0xFF0E2E72,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: !hasAny
                ? Text(
                    'Preview akan muncul setelah kamu mengisi nama kelas, jurusan, dan semester.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(
                        0.45,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.isEmpty
                            ? 'Nama kelas belum diisi'
                            : n,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withOpacity(
                            n.isEmpty
                                ? 0.45
                                : 0.85,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (j.isNotEmpty)
                            chip(
                              Icons.school_rounded,
                              j,
                            ),
                          if (s.isNotEmpty)
                            chip(
                              Icons.filter_9_plus_rounded,
                              'Semester $s',
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar
    extends
        StatelessWidget {
  final bool saving;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final String saveText;

  const _BottomBar({
    required this.saving,
    required this.onCancel,
    required this.onSave,
    required this.saveText,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    const double h = 46;
    const double r = 14;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: h,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    r,
                  ),
                ),
                side: BorderSide(
                  color: Colors.black.withOpacity(
                    0.14,
                  ),
                ),
                foregroundColor: Colors.black.withOpacity(
                  0.78,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              child: const Text(
                'Batal',
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: h,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    r,
                  ),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: saving
                    ? const SizedBox(
                        key: ValueKey(
                          'loading',
                        ),
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        saveText,
                        key: const ValueKey(
                          'text',
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DividerSoft
    extends
        StatelessWidget {
  const _DividerSoft();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.black.withOpacity(
        0.06,
      ),
    );
  }
}
