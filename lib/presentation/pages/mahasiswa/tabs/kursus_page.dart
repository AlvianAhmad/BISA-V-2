import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/course_entity.dart';
import '../../../viewmodels/mahasiswa/kursus_viewmodel.dart';
import 'tambah_kursus_page.dart';

class KursusPage
    extends
        StatefulWidget {
  const KursusPage({
    super.key,
  });

  @override
  State<
    KursusPage
  >
  createState() => _KursusPageState();
}

class _KursusPageState
    extends
        State<
          KursusPage
        > {
  @override
  void initState() {
    super.initState();
    // ✅ load my courses sekali setelah widget ready
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        if (!mounted) return;
        context
            .read<
              KursusViewModel
            >()
            .init();
      },
    );
  }

  Future<
    void
  >
  _openTambahKursusSheet() async {
    final selectedCourses =
        await showModalBottomSheet<
          List<
            CourseEntity
          >
        >(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(
            0.35,
          ),
          builder:
              (
                sheetContext,
              ) {
                return SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(
                          20,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom:
                            MediaQuery.of(
                              sheetContext,
                            ).viewInsets.bottom +
                            20,
                      ),
                      child: const TambahKursusPage(),
                    ),
                  ),
                );
              },
        );

    if (!mounted) return;
    if (selectedCourses ==
            null ||
        selectedCourses.isEmpty)
      return;

    // ✅ anti _debugLocked: jalankan setelah sheet bener2 close
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) async {
        if (!mounted) return;
        await context
            .read<
              KursusViewModel
            >()
            .enrollCourses(
              selectedCourses,
            );

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              "Berhasil enroll ${selectedCourses.length} kursus",
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bottomSafe = MediaQuery.of(
      context,
    ).padding.bottom;
    const floatingNavReserve = 92.0;

    return Consumer<
      KursusViewModel
    >(
      builder:
          (
            context,
            vm,
            _,
          ) {
            final courses = vm.filteredMyCourses;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                floatingNavReserve +
                    bottomSafe,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER + TOMBOL TAMBAH
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kursus Saya",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                            0xFF002F6C,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          999,
                        ),
                        onTap: _openTambahKursusSheet,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(
                              0xFF002F6C,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  /// SEARCH BAR (pakai vm)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: vm.searchController,
                            onChanged: vm.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: "Cari Kursus...",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (vm.searchController.text.isNotEmpty)
                          IconButton(
                            onPressed: vm.clearSearch,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  if (vm.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 40,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (courses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 40,
                        ),
                        child: Text(
                          "Kursus tidak ditemukan",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: courses
                          .map(
                            (
                              course,
                            ) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              child: _CourseCard(
                                course: course,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          },
    );
  }
}

class _CourseCard
    extends
        StatelessWidget {
  final CourseEntity course;

  const _CourseCard({
    required this.course,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final progress = course.progress;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.06,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(
                20,
              ),
              topRight: Radius.circular(
                20,
              ),
            ),
            child: Image.asset(
              course.image,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                    _,
                    __,
                    ___,
                  ) => Container(
                    height: 140,
                    color: const Color(
                      0xFFE9F0FF,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Color(
                          0xFF002F6C,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(
                      0xFF002F6C,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  course.lecturer,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.group,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      "${course.students} Mahasiswa",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Project Progress",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(
                          0xFF002F6C,
                        ),
                      ),
                    ),
                    Text(
                      "${(progress * 100).round()}%",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(
                          0xFF002F6C,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                  child: LinearProgressIndicator(
                    value: progress.clamp(
                      0.0,
                      1.0,
                    ),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(
                      0xFF4A7CFF,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
