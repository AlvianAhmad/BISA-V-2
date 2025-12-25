// lib/presentation/pages/admin/jadwal/jadwal_admin_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/jadwal.dart';
import '../../../viewmodels/admin/jadwal/jadwal_view_model.dart';
import 'tambah_jadwal_page.dart';
import 'edit_jadwal_page.dart';

// ================== GLOBAL THEME ==================
const Color kJadwalPrimary = Color(0xFF0E2E72);
const Color kJadwalPrimary2 = Color(0xFF1B3C9E);
const Color kJadwalBg = Color(0xFFF5F6FA);
const Color kJadwalTextDark = Color(0xFF1A2552);
const Color kJadwalMuted = Color(0xFF6F7AA6);

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Jadwal> _applySearch(List<Jadwal> data) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return data;
    return data.where((j) {
      return j.mataKuliah.toLowerCase().contains(q) ||
          j.dosen.toLowerCase().contains(q) ||
          j.kelas.toLowerCase().contains(q) ||
          j.hari.toLowerCase().contains(q) ||
          j.jam.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<JadwalViewModel>();

    return Scaffold(
      backgroundColor: kJadwalBg,
      appBar: AppBar(
        backgroundColor: kJadwalPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jadwal Perkuliahan',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: SafeArea(
        child: StreamBuilder<List<Jadwal>>(
          stream: vm.jadwalStream(),
          builder: (context, snapshot) {
            final all = snapshot.data ?? const <Jadwal>[];
            final data = _applySearch(all);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // HEADER biru
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
                        builder: (_) => const TambahJadwalPage(),
                      ),
                    ),
                  ),
                ),

                // LIST KONTEN (langsung sliver list, jangan dibungkus scroll lain)
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

      // ================= FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: kJadwalPrimary,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahJadwalPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  SliverList _buildContentSliver({
    required BuildContext context,
    required JadwalViewModel vm,
    required AsyncSnapshot<List<Jadwal>> snapshot,
    required List<Jadwal> all,
    required List<Jadwal> data,
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
            icon: Icons.calendar_month_rounded,
            title: 'Belum ada jadwal',
            subtitle: 'Tambah jadwal pertama kamu biar rapi.',
            actionLabel: 'Tambah Jadwal',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahJadwalPage()),
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
        final j = data[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ScheduleCardV2(
            jadwal: j,
            onMore: () =>
                _openActionsSheet(context: context, jadwal: j, vm: vm),
          ),
        );
      }, childCount: data.length),
    );
  }

  Future<void> _openActionsSheet({
    required BuildContext context,
    required Jadwal jadwal,
    required JadwalViewModel vm,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return _ActionSheet(
          title: jadwal.mataKuliah,
          subtitle: '${jadwal.hari}, ${jadwal.jam} • ${jadwal.kelas}',
          onEdit: () async {
            Navigator.pop(context);

            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditJadwalPage(jadwal: jadwal)),
            );
          },

          onDelete: () async {
            Navigator.pop(context);
            final ok = await _confirmDelete(context, jadwal.mataKuliah);
            if (ok == true) {
              await vm.deleteJadwal(jadwal.id);
            }
          },
        );
      },
    );
  }

  static Future<bool?> _confirmDelete(BuildContext context, String mk) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jadwal'),
        content: Text('Yakin hapus "$mk"?'),
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

// ================== HERO HEADER ==================

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
      decoration: const BoxDecoration(color: kJadwalPrimary),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Manajemen Jadwal Perkuliahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Kelola dan pantau jadwal perkuliahan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // SEARCH (glass)
          _GlassSearch(controller: controller, onChanged: onChanged),
          const SizedBox(height: 12),

          // STATS
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
                    hintText: 'Cari mata kuliah / dosen / kelas...',
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ================== CARD V2 ==================

class _ScheduleCardV2 extends StatelessWidget {
  final Jadwal jadwal;
  final VoidCallback onMore;

  const _ScheduleCardV2({required this.jadwal, required this.onMore});

  Color _accentForDay(String hari) {
    final h = hari.toLowerCase();
    if (h.contains('senin')) return const Color(0xFF6366F1);
    if (h.contains('selasa')) return const Color(0xFF06B6D4);
    if (h.contains('rabu')) return const Color(0xFF22C55E);
    if (h.contains('kamis')) return const Color(0xFFF59E0B);
    if (h.contains('jumat') || h.contains('jum\'at'))
      return const Color(0xFFEF4444);
    if (h.contains('sabtu')) return const Color(0xFF8B5CF6);
    if (h.contains('minggu')) return const Color(0xFFEC4899);
    return kJadwalPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForDay(jadwal.hari);

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
          // CARD
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
                        jadwal.mataKuliah,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w900,
                          color: kJadwalTextDark,
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
                          color: kJadwalMuted.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // META
                Row(
                  children: [
                    _MetaChip(icon: Icons.class_rounded, text: jadwal.kelas),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetaChip(
                        icon: Icons.person_rounded,
                        text: jadwal.dosen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // TIME PILL
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
                        color: kJadwalMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${jadwal.hari} • ${jadwal.jam}',
                          style: const TextStyle(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w800,
                            color: kJadwalMuted,
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
          Icon(icon, size: 16, color: kJadwalMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kJadwalTextDark,
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

class _ActionSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.8,
                        color: kJadwalTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kJadwalMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                color: kJadwalPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: kJadwalPrimary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: kJadwalTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kJadwalMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kJadwalPrimary,
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
// ================== HELPERS FOR CURVED WHITE CONTENT ==================

class _ContentSliverWrapper extends StatelessWidget {
  final Widget sliver;

  const _ContentSliverWrapper({required this.sliver});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      slivers: [sliver],
    );
  }
}

class _HeaderWithOverlappingContent extends StatelessWidget {
  final Widget header;
  final Widget sliverContent;

  const _HeaderWithOverlappingContent({
    required this.header,
    required this.sliverContent,
  });

  @override
  Widget build(BuildContext context) {
    // tinggi area header (atur sesuai feel yang kamu mau)
    const double headerHeight = 250;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // HEADER (biru) jadi background
        SizedBox(height: headerHeight, child: header),

        // WHITE CONTENT yang "naik" nabrak header
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight - 40, // makin kecil => makin nabrak
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 120),
              child: _ContentSliverWrapper(sliver: sliverContent),
            ),
          ),
        ),

        // Spacer bawah biar konten ga kepotong (karena Positioned)
        const SizedBox(height: headerHeight + 1000),
      ],
    );
  }
}
