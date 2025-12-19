import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetAvailableCourses {
  final CourseRepository repo;
  GetAvailableCourses(
    this.repo,
  );

  Future<
    List<
      CourseEntity
    >
  >
  call() => repo.getAvailableCourses();
}
