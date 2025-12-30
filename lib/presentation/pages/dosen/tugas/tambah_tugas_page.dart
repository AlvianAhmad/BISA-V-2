// lib/presentation/pages/dosen/tugas/tambah_tugas_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';
import '../../../viewmodels/admin/kelas/kelas_view_model.dart';

class TambahTugasPage
    extends
        StatefulWidget {
  const TambahTugasPage({
    super.key,
  });

  @override
  State<
    TambahTugasPage
  >
  createState() => _TambahTugasPageState();
}

class _TambahTugasPageState
    extends
        State<
          TambahTugasPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();

  final judul = TextEditingController();
  final deskripsi = TextEditingController();
  String? kelas;

  DateTime? deadline;
  bool _saving = false;

  static const Color _bg = Color(
    0xFFF6F7FB,
  );
  static const Color _primary2 = Color(
    0xFF0E2E72,
  );

  @override
  void dispose() {
    judul.dispose();
    deskripsi.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final tugasVM = context
        .watch<
          TugasViewModel
        >();
    final kelasVM = context
        .watch<
          KelasViewModel
        >();

    final kelasList =
        kelasVM.kelasList
            .map(
              (
                e,
              ) => e.nama.trim(),
            )
            .where(
              (
                e,
              ) => e.isNotEmpty,
            )
            .toSet()
            .toList()
          ..sort();

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
          'Tambah Tugas',
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
                children: [
                  // Header biru
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

                  // Card overlap
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
                                icon: Icons.add_box,
                                title: 'Detail Tugas',
                                caption: 'Lengkapi informasi tugas.',
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              _ModernField(
                                label: 'Judul',
                                hint: 'Contoh: Pertemuan 1',
                                controller: judul,
                                icon: Icons.menu_book_rounded,
                                textInputAction: TextInputAction.next,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Deskripsi',
                                hint: 'Berikan deskripsi tugas',
                                controller: deskripsi,
                                icon: Icons.description_rounded,
                                textInputAction: TextInputAction.newline,
                                maxLines: 4,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernDropdown(
                                label: 'Kelas',
                                hint: 'Pilih Kelas',
                                icon: Icons.class_rounded,
                                value: kelas,
                                items: kelasList,
                                onChanged:
                                    (
                                      v,
                                    ) => setState(
                                      () => kelas = v?.trim(),
                                    ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),
                              const _DividerSoft(),
                              const SizedBox(
                                height: 18,
                              ),

                              _PickerTile(
                                label: 'Deadline',
                                value:
                                    deadline ==
                                        null
                                    ? 'Pilih tanggal'
                                    : _formatDate(
                                        deadline!,
                                      ),
                                icon: Icons.calendar_today_rounded,
                                isFilled:
                                    deadline !=
                                    null,
                                onTap: () async {
                                  final now = DateTime.now();
                                  final initial =
                                      (deadline !=
                                              null &&
                                          deadline!.isAfter(
                                            now,
                                          ))
                                      ? deadline!
                                      : now;

                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: initial,
                                    firstDate: now,
                                    lastDate: DateTime(
                                      2100,
                                    ),
                                  );

                                  if (picked !=
                                      null) {
                                    setState(
                                      () => deadline = picked,
                                    );
                                  }
                                },
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              _PreviewTugasCard(
                                label: 'Preview',
                                judul: judul.text,
                                deskripsi: deskripsi.text,
                                kelas:
                                    kelas ??
                                    'Belum diisi',
                                deadline:
                                    deadline ??
                                    DateTime.now(),
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
                                  saveLabel: 'Simpan Tugas',
                                  onCancel: _saving
                                      ? null
                                      : () => Navigator.pop(
                                          context,
                                          false,
                                        ),
                                  onSave: _saving
                                      ? null
                                      : () => _save(
                                          tugasVM,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  String _formatDate(
    DateTime d,
  ) {
    final y = d.year.toString().padLeft(
      4,
      '0',
    );
    final m = d.month.toString().padLeft(
      2,
      '0',
    );
    final day = d.day.toString().padLeft(
      2,
      '0',
    );
    return '$day/$m/$y';
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
  _save(
    TugasViewModel vm,
  ) async {
    if (_saving) return;

    final valid =
        _formKey.currentState?.validate() ??
        false;
    if (!valid) return;

    if (deadline ==
        null) {
      _toast(
        'Deadline wajib dipilih',
      );
      return;
    }

    if (kelas ==
            null ||
        kelas!.isEmpty) {
      _toast(
        'Kelas wajib dipilih',
      );
      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      await vm.tambahTugas(
        Tugas(
          id: '',
          judul: judul.text.trim(),
          deskripsi: deskripsi.text.trim(),
          kelas: kelas!.trim(),
          deadline: deadline!,
        ),
      );

      if (!mounted) return;

      _showTopToast(
        context,
        message: 'Tugas berhasil ditambahkan',
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
        'Gagal menambahkan tugas',
      );
      setState(
        () => _saving = false,
      );
    }
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

/// =======================================================================
/// ============================  UI WIDGETS  =============================
/// =======================================================================

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
  final VoidCallback onChanged;
  final int maxLines;

  const _ModernField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.textInputAction,
    required this.onChanged,
    this.maxLines = 1,
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
            maxLines: maxLines,
            keyboardType:
                maxLines >
                    1
                ? TextInputType.multiline
                : TextInputType.text,
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

class _PickerTile
    extends
        StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFilled;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.isFilled,
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
        Material(
          color: const Color(
            0xFFF3F5FF,
          ),
          borderRadius: BorderRadius.circular(
            16,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              16,
            ),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(
                    0.7,
                  ),
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
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: _primary,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isFilled
                            ? Colors.black.withOpacity(
                                0.86,
                              )
                            : Colors.black.withOpacity(
                                0.45,
                              ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Colors.black.withOpacity(
                      0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
                        key: const ValueKey(
                          'text',
                        ),
                        saveLabel,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernDropdown
    extends
        StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<
    String
  >
  items;
  final ValueChanged<
    String?
  >
  onChanged;

  const _ModernDropdown({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    final String? safeValue =
        (value !=
                null &&
            items.contains(
              value,
            ))
        ? value
        : null;

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
          child:
              DropdownButtonFormField<
                String
              >(
                value: safeValue,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                ),
                validator:
                    (
                      v,
                    ) =>
                        v ==
                            null
                        ? '$label wajib dipilih'
                        : null,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: _primary,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(
                      0.35,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                items: items
                    .map(
                      (
                        e,
                      ) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
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

class _PreviewTugasCard
    extends
        StatelessWidget {
  final String label;
  final String judul;
  final String deskripsi;
  final String kelas;
  final DateTime deadline;

  const _PreviewTugasCard({
    required this.label,
    required this.judul,
    required this.deskripsi,
    required this.kelas,
    required this.deadline,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasAny =
        judul.trim().isNotEmpty ||
        deskripsi.trim().isNotEmpty ||
        kelas.trim().isNotEmpty;

    Widget item({
      required IconData icon,
      required String title,
      required String value,
    }) {
      if (value.trim().isEmpty) return const SizedBox();

      return Padding(
        padding: const EdgeInsets.only(
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color:
                        const Color(
                          0xFF1B3C9E,
                        ).withOpacity(
                          0.1,
                        ),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: const Color(
                      0xFF0E2E72,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 46,
                top: 6,
              ),
              child: Text(
                value,
                softWrap: true,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(
                    0.75,
                  ),
                  height: 1.5,
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
      padding: const EdgeInsets.all(
        16,
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
      child: hasAny
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item(
                  icon: Icons.menu_book_rounded,
                  title: 'Judul',
                  value: judul,
                ),
                item(
                  icon: Icons.description_rounded,
                  title: 'Deskripsi',
                  value: deskripsi,
                ),
                item(
                  icon: Icons.class_rounded,
                  title: 'Kelas',
                  value: kelas,
                ),
                item(
                  icon: Icons.calendar_today_rounded,
                  title: 'Deadline',
                  value: '${deadline.day}/${deadline.month}/${deadline.year}',
                ),
              ],
            )
          : Text(
              'Preview akan muncul setelah data diisi.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(
                  0.45,
                ),
              ),
            ),
    );
  }
}
