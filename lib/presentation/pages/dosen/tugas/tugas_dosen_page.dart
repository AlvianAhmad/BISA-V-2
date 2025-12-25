// lib/presentation/pages/admin/tugas/tugas_admin_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/tugas.dart';
import '../../../viewmodels/admin/tugas/tugas_view_model.dart';
import 'tambah_tugas_page.dart';
import 'edit_tugas_page.dart';

// ================== GLOBAL THEME (samakan vibe jadwal) ==================
const Color kTugasPrimary = Color(0xFF0E2E72);
const Color kTugasPrimary2 = Color(0xFF1B3C9E);
const Color kTugasBg = Color(0xFFF5F6FA);
const Color kTugasTextDark = Color(0xFF1A2552);
const Color kTugasMuted = Color(0xFF6F7AA6);

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Tugas> _applySearch(List<Tugas> data) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return data;

    return data.where((t) {
      final judul = t.judul.toLowerCase();
      final kelas = t.kelas.toLowerCase();
      // deadline dicari pakai string juga biar fleksibel
      final dl = _fmtDeadline(t.deadline).toLowerCase();

      return judul.contains(q) || kelas.contains(q) || dl.contains(q);
    }).toList();
  }

  static String _fmtDeadline(DateTime d) {
    // format simple: "dd/MM/yyyy HH:mm"
    final local = d.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TugasViewModel>();

    return Scaffold(
      backgroundColor: kTugasBg,

      appBar: AppBar(
        backgroundColor: kTugasPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: SafeArea(
        child: StreamBuilder<List<Tugas>>(
          stream: vm.tugasStream(),
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <Tugas>[];
            final data = _applySearch(all);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    controller: _search,
                    query: _query,
                    total: all.length,
                    shown: data.length,
                    onChanged: (v) => setState(() => _query = v),
                    onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TambahTugasPage(),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
        backgroundColor: kTugasPrimary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahTugasPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  SliverList _buildContentSliver({
    required BuildContext context,
    required TugasViewModel vm,
    required AsyncSnapshot<List<Tugas>> snapshot,
    required List<Tugas> all,
    required List<Tugas> data,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverList(
        delegate: SliverChildListDelegate(const [
          SizedBox(height: 24),
          _SkeletonCard(),
          _SkeletonCard(),
          _SkeletonCard(),
        ]),
      );
    }

    if (snapshot.hasError) {
      return SliverList(
        delegate: SliverChildListDelegate(const [
          SizedBox(height: 24),
          _ModernInfo(
            icon: Icons.wifi_off_rounded,
            title: 'Gagal memuat data',
            subtitle: 'Cek koneksi atau coba lagi.',
          ),
        ]),
      );
    }

    if (all.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 18),
          _ModernInfo(
            icon: Icons.assignment_rounded,
            title: 'Belum ada tugas',
            subtitle: 'Tambah tugas pertama kamu biar rapi.',
            actionLabel: 'Tambah Tugas',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahTugasPage()),
            ),
          ),
        ]),
      );
    }

    if (data.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(const [
          SizedBox(height: 18),
          _ModernInfo(
            icon: Icons.search_off_rounded,
            title: 'Tidak ditemukan',
            subtitle: 'Coba kata kunci lain ya.',
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final t = data[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TugasCardV2(
            tugas: t,
            onMore: () => _openActionsSheet(context: context, tugas: t, vm: vm),
          ),
        );
      }, childCount: data.length),
    );
  }

  Future<void> _openActionsSheet({
    required BuildContext context,
    required Tugas tugas,
    required TugasViewModel vm,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return _ActionSheet(
          title: tugas.judul,
          subtitle:
              '${tugas.kelas} • Deadline: ${_fmtDeadline(tugas.deadline)}',
          description: tugas.deskripsi,
          onEdit: () async {
            Navigator.pop(context);

            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditTugasPage(tugas: tugas)),
            );
          },

          onDelete: () async {
            Navigator.pop(context);
            final ok = await _confirmDelete(context, tugas.judul);
            if (ok == true) {
              await vm.hapusTugas(tugas.id);
            }
          },
        );
      },
    );
  }

  static Future<bool?> _confirmDelete(BuildContext context, String judul) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tugas'),
        content: Text('Yakin hapus "$judul"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ================== HERO HEADER (copy vibe jadwal) ==================

class _HeroHeader extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int total;
  final int shown;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const _HeroHeader({
    required this.controller,
    required this.query,
    required this.total,
    required this.shown,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(color: kTugasPrimary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Tugas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kelola dan pantau tugas untuk setiap kelas',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          _GlassSearch(controller: controller, onChanged: onChanged),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Total',
                  value: '$total',
                  icon: Icons.list_alt_rounded,
                ),
              ),
              const SizedBox(width: 10),
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

class _QuickAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Tambah Tugas',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GlassSearch({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari judul / kelas / deadline...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
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

// ================== CARD V2 (versi tugas, mirip jadwal) ==================

class _TugasCardV2 extends StatelessWidget {
  final Tugas tugas;
  final VoidCallback onMore;

  const _TugasCardV2({required this.tugas, required this.onMore});

  Color _accentForDeadline(DateTime deadline) {
    final d = deadline.toLocal();
    final now = DateTime.now();

    final diff = d.difference(now);

    if (diff.inHours <= 0) return const Color(0xFFEF4444); // lewat
    if (diff.inHours <= 24) return const Color(0xFFF59E0B); // < 1 hari
    if (diff.inDays <= 3) return const Color(0xFF06B6D4); // <= 3 hari
    return const Color(0xFF22C55E); // aman
  }

  static String _fmtDeadline(DateTime d) {
    final local = d.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForDeadline(tugas.deadline);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
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
                        tugas.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w900,
                          color: kTugasTextDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onMore,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: kTugasMuted.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ DESKRIPSI
                if (tugas.deskripsi.trim().isNotEmpty) ...[
                  Text(
                    tugas.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                      color: kTugasMuted.withOpacity(0.95),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // META
                Row(
                  children: [
                    _MetaChip(icon: Icons.class_rounded, text: tugas.kelas),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.event_available_rounded,
                        text: 'Deadline: ${_fmtDeadline(tugas.deadline)}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // DEADLINE PILL
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: kTugasMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _fmtDeadline(tugas.deadline),
                          style: const TextStyle(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w800,
                            color: kTugasMuted,
                          ),
                        ),
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
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kTugasMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kTugasTextDark,
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

// ================== ACTION SHEET (copy jadwal) ==================

class _ActionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description; // ✅ tambah
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionSheet({
    required this.title,
    required this.subtitle,
    required this.description, // ✅ tambah
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final desc = description.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // ✅ rata tengah
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center, // ✅ rata tengah
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.8,
                        color: kTugasTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center, // ✅ rata tengah
                      style: const TextStyle(
                        color: kTugasMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // ✅ DESKRIPSI (muncul kalau ada)
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _ExpandableText(text: desc),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit'),
                onTap: onEdit,
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onTap: onDelete,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== EMPTY / INFO ==================

class _ModernInfo extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kTugasPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: kTugasPrimary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: kTugasTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTugasMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTugasPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = double.infinity, double h = 12}) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(w: 180, h: 14),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: bar(h: 12)),
                const SizedBox(width: 10),
                Expanded(child: bar(h: 12)),
              ],
            ),
            const SizedBox(height: 12),
            bar(h: 36),
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({super.key, required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const int _collapsedLines = 3;

  bool _expanded = false;
  bool _canExpand = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // reset saat rebuild
    _expanded = false;
  }

  bool _checkOverflow({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    return tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.text.trim();
    if (t.isEmpty) return const SizedBox.shrink();

    final style = TextStyle(
      color: kTugasMuted.withOpacity(0.95),
      fontWeight: FontWeight.w700,
      fontSize: 12.8,
      height: 1.35,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final overflow = _checkOverflow(
          text: t,
          style: style,
          maxWidth: constraints.maxWidth,
          maxLines: _collapsedLines,
        );

        // simpan hasil cek overflow (biar tombol cuma muncul kalau perlu)
        _canExpand = overflow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              t,
              textAlign: TextAlign.center,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: style,
            ),
            if (_canExpand) ...[
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    _expanded ? 'Tutup' : 'Lihat selengkapnya',
                    style: TextStyle(
                      color: kTugasPrimary2,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
