import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/jadwal.dart';
import '../../../viewmodels/admin/jadwal/jadwal_view_model.dart';

class TambahJadwalPage
    extends
        StatefulWidget {
  const TambahJadwalPage({
    super.key,
  });

  @override
  State<
    TambahJadwalPage
  >
  createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState
    extends
        State<
          TambahJadwalPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();

  final mataKuliah = TextEditingController();
  final dosen = TextEditingController();
  final kelas = TextEditingController();

  String _hari = '';
  String _jam = '';
  bool _saving = false;

  // ====== MODERN THEME ======
  static const Color _bg = Color(
    0xFFF6F7FB,
  );
  static const Color _primary = Color(
    0xFF1B3C9E,
  );
  static const Color _primary2 = Color(
    0xFF0E2E72,
  );
  // ignore: unused_field
  static const Color _card = Colors.white;

  final List<
    String
  >
  _hariList = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  @override
  void dispose() {
    mataKuliah.dispose();
    dosen.dispose();
    kelas.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder:
          (
            context,
            child,
          ) {
            // bikin time picker lebih modern + konsisten warna
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
        null)
      return;

    // format 2 digit
    final hh = picked.hour.toString().padLeft(
      2,
      '0',
    );
    final mm = picked.minute.toString().padLeft(
      2,
      '0',
    );

    setState(
      () => _jam = '$hh:$mm',
    );
  }

  Future<
    void
  >
  _save(
    JadwalViewModel vm,
  ) async {
    if (_saving) return;

    final validForm =
        _formKey.currentState?.validate() ??
        false;

    if (!validForm) return;

    if (_hari.isEmpty) {
      _toast(
        'Hari wajib dipilih',
      );
      return;
    }

    if (_jam.isEmpty) {
      _toast(
        'Jam wajib dipilih',
      );
      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      await vm.tambahJadwal(
        Jadwal(
          id: '',
          mataKuliah: mataKuliah.text.trim(),
          dosen: dosen.text.trim(),
          kelas: kelas.text.trim(),
          hari: _hari,
          jam: _jam,
        ),
      );

      if (!mounted) return;
      Navigator.pop(
        context,
      );
    } catch (
      _
    ) {
      if (!mounted) return;
      _toast(
        'Gagal menyimpan jadwal. Coba lagi.',
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
          JadwalViewModel
        >();

    return Scaffold(
      backgroundColor: _bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary2,
        surfaceTintColor: _primary2,

        foregroundColor: Colors.white, // ⭐ ini kuncinya

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Tambah Jadwal',
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
                  // 🔵 biru FULL layar + ikut scroll
                  Container(
                    height: 160, // atur panjang biru
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _primary2,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          28,
                        ),
                        bottomRight: Radius.circular(
                          28,
                        ),
                      ),
                    ),
                  ),

                  // 🤍 area konten dikasih padding 16, card overlap ditarik ke atas
                  Transform.translate(
                    offset: const Offset(
                      0,
                      -120,
                    ), // 🔼 card naik lebih ke atas
                    // atur besar overlap
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

                              _SectionTitle(
                                icon: Icons.edit_note_rounded,
                                title: 'Detail Jadwal',
                                caption: 'Lengkapi informasi utama mata kuliah.',
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              _ModernField(
                                label: 'Mata Kuliah',
                                hint: 'Contoh: Mobile Programming',
                                controller: mataKuliah,
                                icon: Icons.menu_book_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Dosen',
                                hint: 'Contoh: Muhamad Fauzan Iqbal',
                                controller: dosen,
                                icon: Icons.person_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              _ModernField(
                                label: 'Kelas',
                                hint: 'Contoh: TI-3A',
                                controller: kelas,
                                icon: Icons.class_rounded,
                                textInputAction: TextInputAction.done,
                              ),

                              const SizedBox(
                                height: 22,
                              ),
                              _DividerSoft(),
                              const SizedBox(
                                height: 18,
                              ),

                              _SectionTitle(
                                icon: Icons.schedule_rounded,
                                title: 'Waktu',
                                caption: 'Pilih hari dan jam perkuliahan.',
                              ),
                              const SizedBox(
                                height: 14,
                              ),

                              Text(
                                'Hari',
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
                                height: 10,
                              ),

                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _hariList.map(
                                  (
                                    h,
                                  ) {
                                    final selected =
                                        _hari ==
                                        h;
                                    return ChoiceChip(
                                      label: Text(
                                        h,
                                      ),
                                      selected: selected,
                                      onSelected:
                                          (
                                            _,
                                          ) => setState(
                                            () => _hari = h,
                                          ),

                                      showCheckmark: true,
                                      checkmarkColor: const Color(
                                        0xFF22C55E,
                                      ), // ✅ hijau

                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : _primary2,
                                      ),
                                      selectedColor: _primary,
                                      backgroundColor: const Color(
                                        0xFFEFF2FF,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14,
                                        ),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    );
                                  },
                                ).toList(),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              _PickerTile(
                                label: 'Jam',
                                value: _jam.isEmpty
                                    ? 'Pilih jam (contoh 09:00)'
                                    : _jam,
                                icon: Icons.access_time_rounded,
                                onTap: _pickTime,
                                isFilled: _jam.isNotEmpty,
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              _PreviewCard(
                                mataKuliah: mataKuliah.text.trim(),
                                dosen: dosen.text.trim(),
                                kelas: kelas.text.trim(),
                                hari: _hari,
                                jam: _jam,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // spacer biar scroll bawah aman (karena card dinaikkan)
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
///   UI WIDGETS (MODERN)
/// =======================

// ignore: unused_element
class _TopGradientHeader
    extends
        StatelessWidget {
  final String title;
  final String subtitle;

  const _TopGradientHeader({
    required this.title,
    required this.subtitle,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
  );
  static const Color _primary2 = Color(
    0xFF0E2E72,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            _primary2,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            18,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButtonPill(
                onTap: () => Navigator.pop(
                  context,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(
                          0.85,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
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

class _BackButtonPill
    extends
        StatelessWidget {
  final VoidCallback onTap;
  const _BackButtonPill({
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white.withOpacity(
        0.16,
      ),
      borderRadius: BorderRadius.circular(
        16,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

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

  const _ModernField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.textInputAction,
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
                ) {
                  // biar preview card update realtime
                  (context
                          as Element)
                      .markNeedsBuild();
                },
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

class _PreviewCard
    extends
        StatelessWidget {
  final String mataKuliah;
  final String dosen;
  final String kelas;
  final String hari;
  final String jam;

  const _PreviewCard({
    required this.mataKuliah,
    required this.dosen,
    required this.kelas,
    required this.hari,
    required this.jam,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final mk = mataKuliah.trim();
    final ds = dosen.trim();
    final kl = kelas.trim();

    final hasAny =
        mk.isNotEmpty ||
        ds.isNotEmpty ||
        kl.isNotEmpty ||
        hari.isNotEmpty ||
        jam.isNotEmpty;

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
                    'Preview akan muncul setelah kamu mengisi mata kuliah, hari, dan jam.',
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
                        mk.isEmpty
                            ? 'Mata kuliah belum diisi'
                            : mk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withOpacity(
                            mk.isEmpty
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
                          if (hari.isNotEmpty)
                            chip(
                              Icons.calendar_today_rounded,
                              hari,
                            ),
                          if (jam.isNotEmpty)
                            chip(
                              Icons.access_time_rounded,
                              jam,
                            ),
                          if (kl.isNotEmpty)
                            chip(
                              Icons.class_rounded,
                              kl,
                            ),
                        ],
                      ),
                      if (ds.isNotEmpty) ...[
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: Colors.black.withOpacity(
                                0.45,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Expanded(
                              child: Text(
                                ds,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(
                                    0.62,
                                  ),
                                ),
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
    );
  }
}

class _BottomBar
    extends
        StatelessWidget {
  final bool saving;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const _BottomBar({
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  static const Color _primary = Color(
    0xFF1B3C9E,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    const double h = 46; // ✅ tinggi sama
    const double r = 14; // ✅ radius sama

    return Row(
      children: [
        // ✅ Batal
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

        // ✅ Simpan
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
                    : const Text(
                        key: ValueKey(
                          'text',
                        ),
                        'Simpan Jadwal',
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
