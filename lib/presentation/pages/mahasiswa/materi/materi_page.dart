import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/materi.dart';
import '../../../viewmodels/mahasiswa/materi_viewmodel.dart';

// ===== THEME (samakan dengan halaman lain) =====
const Color
kBg = Color(
  0xFFF5F6FA,
);
const Color
kTextDark = Color(
  0xFF1A2552,
);
const Color
kMuted = Color(
  0xFF6F7AA6,
);
const Color
kPrimary = Color(
  0xFF1B3C9E,
);

class MateriPage
    extends
        StatelessWidget {
  final String kelasId;
  const MateriPage({
    super.key,
    required this.kelasId,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .watch<
          MateriViewModel
        >();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text(
          'Materi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: kTextDark,
        elevation: 0,
      ),
      body:
          StreamBuilder<
            List<
              Materi
            >
          >(
            stream: vm.getMateriByKelas(
              kelasId,
            ),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                      ),
                    );
                  }

                  final list =
                      snapshot.data ??
                      const <
                        Materi
                      >[];

                  // ===== EMPTY STATE =====
                  if (list.isEmpty) {
                    return const _EmptyMateri();
                  }

                  // ===== LIST MATERI =====
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      20,
                    ),
                    itemCount: list.length,
                    separatorBuilder:
                        (
                          _,
                          __,
                        ) => const SizedBox(
                          height: 12,
                        ),
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final m = list[index];

                          final judul = m.judul.isEmpty
                              ? '-'
                              : m.judul;
                          final deskripsi = m.deskripsi.isEmpty
                              ? 'Tidak ada deskripsi'
                              : m.deskripsi;
                          final hasFile =
                              (m.fileUrl?.trim().isNotEmpty ??
                              false);

                          return _MateriCard(
                            judul: judul,
                            deskripsi: deskripsi,
                            hasFile: hasFile,
                            onTap: () {
                              // TODO: buka detail / preview / download
                            },
                          );
                        },
                  );
                },
          ),
    );
  }
}

/// =========================
/// CARD MATERI (1 BARIS)
/// =========================
class _MateriCard
    extends
        StatelessWidget {
  final String judul;
  final String deskripsi;
  final bool hasFile;
  final VoidCallback onTap;

  const _MateriCard({
    required this.judul,
    required this.deskripsi,
    required this.hasFile,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              18,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(
                  0x11000000,
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
              // ICON KIRI
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(
                    0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: kPrimary,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: kMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // ICON KANAN
              if (hasFile)
                const Icon(
                  Icons.download_rounded,
                  color: kPrimary,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =========================
/// EMPTY STATE
/// =========================
class _EmptyMateri
    extends
        StatelessWidget {
  const _EmptyMateri();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: kMuted,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'Belum ada materi',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: kTextDark,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            'Materi akan muncul di sini',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
