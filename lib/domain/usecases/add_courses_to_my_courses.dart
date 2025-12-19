import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class AddCoursesToMyCourses {
  final CourseRepository repo;
  AddCoursesToMyCourses(
    this.repo,
  );

  Future<
    void
  >
  call(
    List<
      CourseEntity
    >
    courses,
  ) => repo.addCoursesToMyCourses(
    courses,
  );
}
