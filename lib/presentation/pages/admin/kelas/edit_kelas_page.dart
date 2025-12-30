// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/kelas.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class EditKelasPage
    extends
        StatefulWidget {
  final Kelas kelas;
  const EditKelasPage({
    super.key,
    required this.kelas,
  });

  @override
  State<
    EditKelasPage
  >
  createState() => _EditKelasPageState();
}

class _EditKelasPageState
    extends
        State<
          EditKelasPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();

  late final TextEditingController nama;
  late final TextEditingController jurusan;
  late final TextEditingController semester;

  bool _saving = false;

  late Kelas _initial;

  // ====== MODERN THEME (samakan EditAbsensi) ======
  static const Color _bg = Color(
    0xFFF6F7FB,
  );
  static const Color _primary = Color(
    0xFF1B3C9E,
  );
  static const Color _primary2 = Color(
    0xFF0E2E72,
  );

  @override
  void initState() {
    super.initState();
    _initial = widget.kelas;

    nama = TextEditingController(
      text: widget.kelas.nama,
    );
    jurusan = TextEditingController(
      text: widget.kelas.jurusan,
    );
    semester = TextEditingController(
      text: widget.kelas.semester,
    );
  }

  @override
  void dispose() {
    nama.dispose();
    jurusan.dispose();
    semester.dispose();
    super.dispose();
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

  Future<
    void
  >
  _update(
    KelasViewModel vm,
  ) async {
    if (_saving) return;

    final valid =
        _formKey.currentState?.validate() ??
        false;
    if (!valid) return;

    final updated = Kelas(
      id: widget.kelas.id,
      nama: nama.text.trim(),
      jurusan: jurusan.text.trim(),
      semester: semester.text.trim(),
    );

    // cek perubahan (biar kalau ga ada perubahan langsung balik)
    final isChanged =
        updated.nama !=
            _initial.nama ||
        updated.jurusan !=
            _initial.jurusan ||
        updated.semester !=
            _initial.semester;

    if (!isChanged) {
      Navigator.pop(
        context,
        false,
      );
      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      await vm.editKelas(
        updated,
      );

      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      );
    } catch (
      _
    ) {
      if (!mounted) return;
      _toast(
        'Gagal update kelas. Coba lagi.',
      );
      setState(
        () => _saving = false,
      );
    }
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
            false,
          ),
        ),
        title: const Text(
          'Edit Kelas',
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
                                icon: Icons.edit_note_rounded,
                                title: 'Detail Kelas',
                                caption: 'Perbarui informasi kelas.',
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              _ModernField(
                                label: 'Nama Kelas',
                                hint: 'Contoh: TI-3A',
                                controller: nama,
                                icon: Icons.class_rounded,
                                textInputAction: TextInputAction.next,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Jurusan',
                                hint: 'Contoh: Teknik Informatika',
                                controller: jurusan,
                                icon: Icons.school_rounded,
                                textInputAction: TextInputAction.next,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Semester',
                                hint: 'Contoh: 3',
                                controller: semester,
                                icon: Icons.stacked_bar_chart_rounded,
                                textInputAction: TextInputAction.done,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),

                              const SizedBox(
                                height: 18,
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
                                  cancelLabel: 'Batal',
                                  saveLabel: 'Update Kelas',
                                  onCancel: _saving
                                      ? null
                                      : () => Navigator.pop(
                                          context,
                                          false,
                                        ),
                                  onSave: _saving
                                      ? null
                                      : () => _update(
                                          vm,
                                        ),
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

          // overlay loading
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

/// =======================
///   UI WIDGETS (SAMA VIBE)
/// =======================

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
          18,
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
  final VoidCallback onChanged;

  const _ModernField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.textInputAction,
    required this.onChanged,
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
                ) => onChanged(),
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
                    0xFF0E2E72,
                  ).withOpacity(
                    0.10,
                  ),
            ),
            child: const Icon(
              Icons.class_rounded,
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
                    'Preview akan muncul setelah kamu mengisi data kelas.',
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
                          chip(
                            Icons.school_rounded,
                            j.isEmpty
                                ? 'Jurusan belum diisi'
                                : j,
                          ),
                          chip(
                            Icons.stacked_bar_chart_rounded,
                            s.isEmpty
                                ? 'Semester belum diisi'
                                : 'Semester $s',
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
  final String cancelLabel;
  final String saveLabel;

  const _BottomBar({
    required this.saving,
    required this.onCancel,
    required this.onSave,
    required this.cancelLabel,
    required this.saveLabel,
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
              child: Text(
                cancelLabel,
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
              child: Text(
                saveLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
