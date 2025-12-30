// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';
import 'package:bisa/presentation/viewmodels/admin/kelas/kelas_view_model.dart';

class EditAbsensiPage
    extends
        StatefulWidget {
  final Absensi absensi;
  const EditAbsensiPage({
    super.key,
    required this.absensi,
  });

  @override
  State<
    EditAbsensiPage
  >
  createState() => _EditAbsensiPageState();
}

class _EditAbsensiPageState
    extends
        State<
          EditAbsensiPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();

  late final TextEditingController judul;
  String? _kelas;

  DateTime _tanggal = DateTime.now();
  String _jamMulai = '';
  String _jamSelesai = '';
  bool _aktif = true;

  bool _saving = false;

  late Absensi _initial;

  // ====== MODERN THEME (samakan) ======
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

    _initial = widget.absensi;

    judul = TextEditingController(
      text: widget.absensi.judul,
    );
    _kelas = widget.absensi.kelas;

    _tanggal = widget.absensi.tanggal;
    _jamMulai = widget.absensi.jamMulai;
    _jamSelesai = widget.absensi.jamSelesai;
    _aktif = widget.absensi.aktif;
  }

  @override
  void dispose() {
    judul.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(
        2020,
      ),
      lastDate: DateTime(
        2100,
      ),
      builder:
          (
            context,
            child,
          ) {
            final theme = Theme.of(
              context,
            );
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: _primary,
                  secondary: _primary,
                ),
              ),
              child: child!,
            );
          },
    );

    if (picked ==
        null) {
      return;
    }
    setState(
      () => _tanggal = picked,
    );
  }

  TimeOfDay _parseTimeOrNow(
    String value,
  ) {
    final parts = value.split(
      ':',
    );
    if (parts.length ==
        2) {
      final hh = int.tryParse(
        parts[0],
      );
      final mm = int.tryParse(
        parts[1],
      );
      if (hh !=
              null &&
          mm !=
              null) {
        return TimeOfDay(
          hour: hh,
          minute: mm,
        );
      }
    }
    return TimeOfDay.now();
  }

  Future<
    void
  >
  _pickTime({
    required bool mulai,
  }) async {
    final initial = mulai
        ? _parseTimeOrNow(
            _jamMulai,
          )
        : _parseTimeOrNow(
            _jamSelesai,
          );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder:
          (
            context,
            child,
          ) {
            final theme = Theme.of(
              context,
            );
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: _primary,
                  secondary: _primary,
                ),
              ),
              child: child!,
            );
          },
    );

    if (picked ==
        null) {
      return;
    }

    final hh = picked.hour.toString().padLeft(
      2,
      '0',
    );
    final mm = picked.minute.toString().padLeft(
      2,
      '0',
    );

    setState(
      () {
        if (mulai) {
          _jamMulai = '$hh:$mm';
        } else {
          _jamSelesai = '$hh:$mm';
        }
      },
    );
  }

  Future<
    void
  >
  _update(
    AbsensiViewModel vm,
  ) async {
    if (_saving) return;

    final valid =
        _formKey.currentState?.validate() ??
        false;
    if (!valid) return;

    if (_jamMulai.isEmpty) {
      _toast(
        'Jam mulai wajib dipilih',
      );
      return;
    }
    if (_jamSelesai.isEmpty) {
      _toast(
        'Jam selesai wajib dipilih',
      );
      return;
    }
    if (_kelas ==
            null ||
        _kelas!.trim().isEmpty) {
      _toast(
        'Kelas wajib dipilih',
      );
      return;
    }

    final updated = widget.absensi.copyWith(
      judul: judul.text.trim(),
      kelas: _kelas!.trim(),
      tanggal: _tanggal,
      jamMulai: _jamMulai,
      jamSelesai: _jamSelesai,
      aktif: _aktif,
    );

    // 🔥 CEK PERUBAHAN
    final isChanged =
        updated.judul !=
            _initial.judul ||
        updated.kelas !=
            _initial.kelas ||
        updated.tanggal !=
            _initial.tanggal ||
        updated.jamMulai !=
            _initial.jamMulai ||
        updated.jamSelesai !=
            _initial.jamSelesai ||
        updated.aktif !=
            _initial.aktif;

    if (!isChanged) {
      Navigator.pop(
        context,
        false,
      ); // ⛔ TIDAK ADA PERUBAHAN
      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      await vm.updateAbsensi(
        updated,
      );

      if (!mounted) return;
      Navigator.pop(
        context,
        true,
      ); // ✅ ADA PERUBAHAN
    } catch (
      _
    ) {
      if (!mounted) return;
      _toast(
        'Gagal update sesi. Coba lagi.',
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

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          AbsensiViewModel
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

    final String? safeKelas =
        (_kelas !=
                null &&
            kelasList.contains(
              _kelas!.trim(),
            ))
        ? _kelas!.trim()
        : null;

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
          'Edit Absensi',
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
                                title: 'Detail Sesi',
                                caption: 'Perbarui informasi sesi absensi.',
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              _ModernField(
                                label: 'Judul Sesi',
                                hint: 'Contoh: Pertemuan 1',
                                controller: judul,
                                icon: Icons.fact_check_rounded,
                                textInputAction: TextInputAction.next,
                                onChanged: () => setState(
                                  () {},
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernDropdown(
                                label: 'Kelas',
                                hint:
                                    safeKelas ==
                                            null &&
                                        (_kelas?.isNotEmpty ??
                                            false)
                                    ? 'Kelas sebelumnya sudah dihapus'
                                    : 'Pilih Kelas',
                                icon: Icons.class_rounded,
                                value: safeKelas,
                                items: kelasList,
                                onChanged:
                                    (
                                      v,
                                    ) {
                                      setState(
                                        () {
                                          _kelas = v?.trim();
                                        },
                                      );
                                    },
                              ),

                              const SizedBox(
                                height: 22,
                              ),
                              _DividerSoft(),
                              const SizedBox(
                                height: 18,
                              ),

                              const _SectionTitle(
                                icon: Icons.schedule_rounded,
                                title: 'Waktu',
                                caption: 'Perbarui tanggal dan jam sesi.',
                              ),
                              const SizedBox(
                                height: 14,
                              ),

                              _PickerTile(
                                label: 'Tanggal',
                                value: _formatDate(
                                  _tanggal,
                                ),
                                icon: Icons.calendar_today_rounded,
                                onTap: _pickTanggal,
                                isFilled: true,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _PickerTile(
                                label: 'Jam Mulai',
                                value: _jamMulai.isEmpty
                                    ? 'Pilih jam mulai'
                                    : _jamMulai,
                                icon: Icons.access_time_rounded,
                                onTap: () => _pickTime(
                                  mulai: true,
                                ),
                                isFilled: _jamMulai.isNotEmpty,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _PickerTile(
                                label: 'Jam Selesai',
                                value: _jamSelesai.isEmpty
                                    ? 'Pilih jam selesai'
                                    : _jamSelesai,
                                icon: Icons.access_time_filled_rounded,
                                onTap: () => _pickTime(
                                  mulai: false,
                                ),
                                isFilled: _jamSelesai.isNotEmpty,
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              _ActiveTile(
                                value: _aktif,
                                onChanged:
                                    (
                                      v,
                                    ) => setState(
                                      () => _aktif = v,
                                    ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              _PreviewAbsensiCard(
                                judul: judul.text.trim(),
                                kelas:
                                    (_kelas ??
                                            '')
                                        .trim(),
                                tanggal: _tanggal,
                                jamMulai: _jamMulai,
                                jamSelesai: _jamSelesai,
                                aktif: _aktif,
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
                                  saveLabel: 'Update Sesi',
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

  static String _formatDate(
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
    return '$y-$m-$day';
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

class _ActiveTile
    extends
        StatelessWidget {
  final bool value;
  final ValueChanged<
    bool
  >
  onChanged;

  const _ActiveTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bg = value
        ? const Color(
            0xFF22C55E,
          ).withOpacity(
            0.10,
          )
        : Colors.black.withOpacity(
            0.04,
          );
    final border = value
        ? const Color(
            0xFF22C55E,
          ).withOpacity(
            0.22,
          )
        : Colors.black.withOpacity(
            0.08,
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: value
                  ? const Color(
                      0xFF22C55E,
                    ).withOpacity(
                      0.18,
                    )
                  : Colors.black.withOpacity(
                      0.06,
                    ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              value
                  ? Icons.check_circle_rounded
                  : Icons.pause_circle_filled_rounded,
              color: value
                  ? const Color(
                      0xFF16A34A,
                    )
                  : Colors.black.withOpacity(
                      0.45,
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
                  'Status Absensi',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(
                      0.82,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value
                      ? 'Aktif (mahasiswa bisa absen)'
                      : 'Nonaktif (tidak bisa absen)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.2,
                    color: Colors.black.withOpacity(
                      0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(
              0xFF22C55E,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewAbsensiCard
    extends
        StatelessWidget {
  final String judul;
  final String kelas;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final bool aktif;

  const _PreviewAbsensiCard({
    required this.judul,
    required this.kelas,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.aktif,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final j = judul.trim();
    final k = kelas.trim();
    final hasAny =
        j.isNotEmpty ||
        k.isNotEmpty ||
        jamMulai.isNotEmpty ||
        jamSelesai.isNotEmpty;

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
                  (aktif
                          ? const Color(
                              0xFF22C55E,
                            )
                          : const Color(
                              0xFFF59E0B,
                            ))
                      .withOpacity(
                        0.12,
                      ),
            ),
            child: Icon(
              aktif
                  ? Icons.verified_rounded
                  : Icons.do_not_disturb_on_rounded,
              color: aktif
                  ? const Color(
                      0xFF16A34A,
                    )
                  : const Color(
                      0xFFB45309,
                    ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: !hasAny
                ? Text(
                    'Preview akan muncul setelah kamu mengisi data sesi.',
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
                        j.isEmpty
                            ? 'Judul belum diisi'
                            : j,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withOpacity(
                            j.isEmpty
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
                            Icons.class_rounded,
                            k.isEmpty
                                ? 'Kelas belum diisi'
                                : k,
                          ),
                          chip(
                            Icons.calendar_today_rounded,
                            _formatDate(
                              tanggal,
                            ),
                          ),
                          if (jamMulai.isNotEmpty)
                            chip(
                              Icons.access_time_rounded,
                              jamMulai,
                            ),
                          if (jamSelesai.isNotEmpty)
                            chip(
                              Icons.access_time_filled_rounded,
                              jamSelesai,
                            ),
                          chip(
                            Icons.toggle_on_rounded,
                            aktif
                                ? 'Aktif'
                                : 'Nonaktif',
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

  static String _formatDate(
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
    return '$y-$m-$day';
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

class _DividerSoft
    extends
        StatelessWidget {
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
