import '../models/course_model.dart';

class CourseLocalDataSource {
  // KURSUS TERSEDIA (catalog)
  final List<
    CourseModel
  >
  _available = const [
    CourseModel(
      image: "assets/images/mopro.png",
      title: "Mobile Programming",
      lecturer: "Muhamad Fauzan Iqbal",
      students: 30,
      progress: 0.0,
    ),
    CourseModel(
      image: "assets/images/mopro.png",
      title: "UI/UX Design",
      lecturer: "Alvian Ahmad Febrian",
      students: 25,
      progress: 0.0,
    ),
    CourseModel(
      image: "assets/images/mopro.png",
      title: "Web Development",
      lecturer: "Muhammad Firdaus",
      students: 40,
      progress: 0.0,
    ),
    CourseModel(
      image: "assets/images/mopro.png",
      title: "Data Mining",
      lecturer: "Dosen Data",
      students: 32,
      progress: 0.0,
    ),
    CourseModel(
      image: "assets/images/mopro.png",
      title: "Machine Learning",
      lecturer: "Dosen ML",
      students: 28,
      progress: 0.0,
    ),
  ];

  // KURSUS YANG SUDAH DIAMBIL (my courses)
  final List<
    CourseModel
  >
  _myCourses = [
    const CourseModel(
      image: "assets/images/mopro.png",
      title: "Mobile Programming",
      lecturer: "Muhamad Fauzan Iqbal",
      students: 30,
      progress: 0.72,
    ),
  ];

  Future<
    List<
      CourseModel
    >
  >
  getAvailableCourses() async {
    return List<
      CourseModel
    >.from(
      _available,
    );
  }

  Future<
    List<
      CourseModel
    >
  >
  getMyCourses() async {
    return List<
      CourseModel
    >.from(
      _myCourses,
    );
  }

  Future<
    void
  >
  addToMyCourses(
    List<
      CourseModel
    >
    newOnes,
  ) async {
    // cegah duplikat (berdasarkan title)
    for (final c in newOnes) {
      final exists = _myCourses.any(
        (
          m,
        ) =>
            m.title ==
            c.title,
      );
      if (!exists)
        _myCourses.add(
          c,
        );
    }
  }
}
