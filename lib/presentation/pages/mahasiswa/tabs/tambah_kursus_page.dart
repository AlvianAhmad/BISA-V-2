import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/course_entity.dart';
import '../../../viewmodels/mahasiswa/kursus_viewmodel.dart';

class TambahKursusPage
    extends
        StatefulWidget {
  const TambahKursusPage({
    super.key,
  });

  @override
  State<
    TambahKursusPage
  >
  createState() => _TambahKursusPageState();
}

class _TambahKursusPageState
    extends
        State<
          TambahKursusPage
        > {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  final Set<
    String
  >
  _selectedTitles = {}; // kunci by title (dummy)

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          KursusViewModel
        >();

    return Material(
      color: Colors.transparent,
      child:
          FutureBuilder<
            List<
              CourseEntity
            >
          >(
            future: vm.loadAvailableCourses(),
            builder:
                (
                  context,
                  snap,
                ) {
                  final isLoading =
                      snap.connectionState ==
                      ConnectionState.waiting;
                  final data =
                      snap.data ??
                      [];

                  final filtered =
                      _query
                          .trim()
                          .isEmpty
                      ? data
                      : data.where(
                          (
                            c,
                          ) {
                            final q = _query.toLowerCase();
                            return c.title.toLowerCase().contains(
                                  q,
                                ) ||
                                c.lecturer.toLowerCase().contains(
                                  q,
                                );
                          },
                        ).toList();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(
                            bottom: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(
                              99,
                            ),
                          ),
                        ),
                      ),

                      Text(
                        "Tambah / Enroll Kursus",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                            0xFF002F6C,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      // search
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF7F9FF,
                          ),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: Colors.grey.shade300,
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
                                controller: _search,
                                onChanged:
                                    (
                                      v,
                                    ) => setState(
                                      () => _query = v,
                                    ),
                                decoration: InputDecoration(
                                  hintText: "Cari kursus tersedia...",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  _search.clear();
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
                        height: 14,
                      ),

                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 40,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder:
                                (
                                  _,
                                  __,
                                ) => const SizedBox(
                                  height: 10,
                                ),
                            itemBuilder:
                                (
                                  context,
                                  i,
                                ) {
                                  final c = filtered[i];
                                  final selected = _selectedTitles.contains(
                                    c.title,
                                  );

                                  return _AvailableCourseTile(
                                    course: c,
                                    selected: selected,
                                    onTap: () {
                                      setState(
                                        () {
                                          if (selected) {
                                            _selectedTitles.remove(
                                              c.title,
                                            );
                                          } else {
                                            _selectedTitles.add(
                                              c.title,
                                            );
                                          }
                                        },
                                      );
                                    },
                                    alreadyEnrolled: vm.myCourses.any(
                                      (
                                        m,
                                      ) =>
                                          m.title ==
                                          c.title,
                                    ),
                                  );
                                },
                          ),
                        ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(
                                context,
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Batal",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedTitles.isEmpty
                                  ? null
                                  : () {
                                      final selectedCourses = data
                                          .where(
                                            (
                                              e,
                                            ) => _selectedTitles.contains(
                                              e.title,
                                            ),
                                          )
                                          .map(
                                            (
                                              e,
                                            ) => CourseEntity(
                                              image: e.image,
                                              title: e.title,
                                              lecturer: e.lecturer,
                                              students: e.students,
                                              progress: 0.0, // progress awal enroll
                                            ),
                                          )
                                          .toList();

                                      Navigator.pop(
                                        context,
                                        selectedCourses,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF002F6C,
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    14,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Enroll (${_selectedTitles.length})",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
          ),
    );
  }
}

class _AvailableCourseTile
    extends
        StatelessWidget {
  final CourseEntity course;
  final bool selected;
  final bool alreadyEnrolled;
  final VoidCallback onTap;

  const _AvailableCourseTile({
    required this.course,
    required this.selected,
    required this.alreadyEnrolled,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Opacity(
      opacity: alreadyEnrolled
          ? 0.6
          : 1,
      child: InkWell(
        onTap: alreadyEnrolled
            ? null
            : onTap,
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: selected
                  ? const Color(
                      0xFF002F6C,
                    )
                  : Colors.grey.shade200,
              width: selected
                  ? 1.4
                  : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.04,
                ),
                blurRadius: 10,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                child: Image.asset(
                  course.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
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
                      course.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(
                          0xFF002F6C,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      course.lecturer,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.group,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          "${course.students} Mahasiswa",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (alreadyEnrolled)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Text(
                          "Sudah diambil",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected
                    ? const Color(
                        0xFF002F6C,
                      )
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
