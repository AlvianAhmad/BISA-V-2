import '../entities/course_entity.dart';

abstract class CourseRepository {
  Future<
    List<
      CourseEntity
    >
  >
  getMyCourses();
  Future<
    List<
      CourseEntity
    >
  >
  getAvailableCourses();

  Future<
    void
  >
  addCoursesToMyCourses(
    List<
      CourseEntity
    >
    courses,
  );
}
