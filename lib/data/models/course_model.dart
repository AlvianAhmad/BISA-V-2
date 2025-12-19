import '../../domain/entities/course_entity.dart';

class CourseModel
    extends
        CourseEntity {
  const CourseModel({
    required super.image,
    required super.title,
    required super.lecturer,
    required super.students,
    required super.progress,
  });

  factory CourseModel.fromMap(
    Map<
      String,
      dynamic
    >
    map,
  ) {
    return CourseModel(
      image:
          (map['image'] ??
                  '')
              .toString(),
      title:
          (map['title'] ??
                  '')
              .toString(),
      lecturer:
          (map['lecturer'] ??
                  '')
              .toString(),
      students:
          (map['students'] ??
                  0)
              as int,
      progress:
          (map['progress'] ??
                  0.0)
              is num
          ? (map['progress']
                    as num)
                .toDouble()
          : 0.0,
    );
  }

  Map<
    String,
    dynamic
  >
  toMap() {
    return {
      'image': image,
      'title': title,
      'lecturer': lecturer,
      'students': students,
      'progress': progress,
    };
  }
}
