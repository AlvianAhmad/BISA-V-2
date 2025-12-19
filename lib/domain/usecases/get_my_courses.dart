import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetMyCourses {
  final CourseRepository repo;

  GetMyCourses(
    this.repo,
  );

  Future<
    List<
      CourseEntity
    >
  >
  call() => repo.getMyCourses();
}
