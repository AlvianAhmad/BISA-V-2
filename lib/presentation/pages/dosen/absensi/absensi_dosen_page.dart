// ignore_for_file: deprecated_member_use, unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/absensi.dart';
import '../../../viewmodels/admin/absensi/absensi_view_model.dart';
import 'tambah_absensi_page.dart';
import 'edit_absensi_page.dart';
import 'kehadiran_absensi_page.dart';

// ================== THEME ==================
const Color kAbsensiPrimary = Color(0xFF0E2E72);
const Color kAbsensiPrimary2 = Color(0xFF1B3C9E);
const Color kAbsensiBg = Color(0xFFF5F6FA);
const Color kAbsensiTextDark = Color(0xFF1A2552);
const Color kAbsensiMuted = Color(0xFF6F7AA6);

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Absensi> _applySearch(List<Absensi> data) {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return data;

    return data.where((a) {
      return a.judul.toLowerCase().contains(q) ||
          a.kelas.toLowerCase().contains(q) ||
          a.jamMulai.toLowerCase().contains(q) ||
          a.jamSelesai.toLowerCase().contains(q) ||
          (a.aktif ? 'aktif' : 'nonaktif').contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AbsensiViewModel>();

    return Scaffold(
      backgroundColor: kAbsensiBg,
      appBar: AppBar(
        backgroundColor: kAbsensiPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          'Sesi Absensi',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: StreamBuilder<List<Absensi>>(
        stream: vm.absensiStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const _ModernInfo(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat',
              subtitle: 'Terjadi kesalahan saat mengambil data',
            );
          }

          final all = snap.data ?? [];
          final data = _applySearch(all);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(
                  controller: _search,
                  query: _query,
                  total: all.length,
                  aktif: all.where((e) => e.aktif).length,
                  onChanged: (v) => setState(() => _query = v),
                  onAdd: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahAbsensiPage(),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: data.isEmpty
                    ? SliverToBoxAdapter(
                        child: const _ModernInfo(
                          icon: Icons.search_off_rounded,
                          title: 'Tidak ditemukan',
                          subtitle: 'Coba kata kunci lain',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final a = data[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AbsensiCard(
                              absensi: a,
                              onToggle: (v) =>
                                  vm.updateAbsensi(a.copyWith(aktif: v)),
                              onOpen: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => KehadiranAbsensiPage(
                                    absensiId: a.id,
                                    judul: a.judul,
                                    kelas: a.kelas,
                                  ),
                                ),
                              ),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditAbsensiPage(absensi: a),
                                ),
                              ),
                              onDelete: () async {
                                await vm.hapusAbsensi(a.id);
                              },
                            ),
                          );
                        }, childCount: data.length),
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kAbsensiPrimary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TambahAbsensiPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ================== CARD ==================

class _AbsensiCard extends StatelessWidget {
  final Absensi absensi;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AbsensiCard({
    required this.absensi,
    required this.onToggle,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              absensi.judul,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: kAbsensiTextDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${absensi.kelas} • ${absensi.jamMulai} - ${absensi.jamSelesai}',
              style: const TextStyle(
                color: kAbsensiMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    absensi.aktif ? 'Status: Aktif' : 'Status: Nonaktif',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: kAbsensiMuted,
                    ),
                  ),
                ),
                Switch(value: absensi.aktif, onChanged: onToggle),
              ],
            ),

            const Divider(height: 20),

            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================== HERO ==================

class _HeroHeader extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final int total;
  final int aktif;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const _HeroHeader({
    required this.controller,
    required this.query,
    required this.total,
    required this.aktif,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(color: kAbsensiPrimary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Absensi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Cari absensi...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== INFO ==================

class _ModernInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModernInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: kAbsensiPrimary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: kAbsensiMuted)),
        ],
      ),
    );
  }
}
