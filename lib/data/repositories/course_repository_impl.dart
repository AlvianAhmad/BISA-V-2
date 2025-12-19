import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl
    implements
        CourseRepository {
  final CourseLocalDataSource local;
  CourseRepositoryImpl(
    this.local,
  );

  @override
  Future<
    List<
      CourseEntity
    >
  >
  getAvailableCourses() async {
    return local.getAvailableCourses();
  }

  @override
  Future<
    List<
      CourseEntity
    >
  >
  getMyCourses() async {
    return local.getMyCourses();
  }

  @override
  Future<
    void
  >
  addCoursesToMyCourses(
    List<
      CourseEntity
    >
    courses,
  ) async {
    final models = courses
        .map(
          (
            e,
          ) => CourseModel(
            image: e.image,
            title: e.title,
            lecturer: e.lecturer,
            students: e.students,
            // default progress awal saat enroll
            progress:
                e.progress ==
                    0
                ? 0.0
                : e.progress,
          ),
        )
        .toList();

    await local.addToMyCourses(
      models,
    );
  }
}
