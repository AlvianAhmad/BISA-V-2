import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tambah_kursus_page.dart'; // pastikan file ini ada & punya TambahKursusForm

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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<
    Map<
      String,
      dynamic
    >
  >
  courseData = [
    {
      "image": "assets/images/mopro.png",
      "title": "Mobile Programming",
      "lecturer": "Muhamad Fauzan Iqbal",
      "students": 30,
      "progress": 0.72,
    },
    {
      "image": "assets/images/mopro.png",
      "title": "UI/UX Design",
      "lecturer": "Alvian Ahmad Febrian",
      "students": 25,
      "progress": 0.45,
    },
    {
      "image": "assets/images/mopro.png",
      "title": "Web Development",
      "lecturer": "Muhammad Firdaus",
      "students": 40,
      "progress": 0.88,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<
    Map<
      String,
      dynamic
    >
  >
  get filteredCourses {
    if (_query.trim().isEmpty) return courseData;

    final q = _query.toLowerCase();
    return courseData.where(
      (
        c,
      ) {
        final title =
            (c["title"] ??
                    "")
                .toString()
                .toLowerCase();
        final lecturer =
            (c["lecturer"] ??
                    "")
                .toString()
                .toLowerCase();
        return title.contains(
              q,
            ) ||
            lecturer.contains(
              q,
            );
      },
    ).toList();
  }

  Future<
    void
  >
  _openTambahKursusSheet() async {
    final selectedCourses =
        await showModalBottomSheet<
          List<
            Map<
              String,
              dynamic
            >
          >
        >(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                20,
              ),
            ),
          ),
          builder:
              (
                context,
              ) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom:
                        MediaQuery.of(
                          context,
                        ).viewInsets.bottom +
                        20,
                  ),
                  // ✅ ganti modal content jadi halaman enroll
                  child: const TambahKursusPage(),
                );
              },
        );

    if (selectedCourses !=
            null &&
        selectedCourses.isNotEmpty) {
      setState(
        () {
          // ✅ cegah duplikat berdasarkan title
          for (final c in selectedCourses) {
            final exists = courseData.any(
              (
                m,
              ) =>
                  m["title"] ==
                  c["title"],
            );
            if (!exists)
              courseData.add(
                c,
              );
          }
        },
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bottomSafe = MediaQuery.of(
      context,
    ).padding.bottom;

    // tinggi navbar (56) + margin bottom nav (16) + jarak aman (20)
    const floatingNavReserve = 92.0;

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
          /// ======================
          /// HEADER + TOMBOL TAMBAH
          /// ======================
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

          /// ======================
          /// SEARCH BAR
          /// ======================
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
                    controller: _searchController,
                    onChanged:
                        (
                          v,
                        ) => setState(
                          () => _query = v,
                        ),
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
                if (_query.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(
                        () => _query = '',
                      );
                    },
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

          /// ======================
          /// LIST KARTU KURSUS
          /// ======================
          if (filteredCourses.isEmpty)
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
              children: filteredCourses
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
  }
}

/// ======================
/// COURSE CARD WIDGET
/// ======================
class _CourseCard
    extends
        StatelessWidget {
  final Map<
    String,
    dynamic
  >
  course;

  const _CourseCard({
    required this.course,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final title =
        (course["title"] ??
                "-")
            .toString();
    final lecturer =
        (course["lecturer"] ??
                "-")
            .toString();
    final students =
        course["students"] ??
        0;
    final progress =
        (course["progress"]
            is num)
        ? course["progress"]
              as num
        : 0;
    final image =
        (course["image"] ??
                "")
            .toString();

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
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(
                20,
              ),
              topRight: Radius.circular(
                20,
              ),
            ),
            child: (image.isNotEmpty)
                ? Image.asset(
                    image,
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
                  )
                : Container(
                    height: 140,
                    color: const Color(
                      0xFFE9F0FF,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: Color(
                          0xFF002F6C,
                        ),
                      ),
                    ),
                  ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  lecturer,
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
                      "$students Mahasiswa",
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
                    value: progress.toDouble().clamp(
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
