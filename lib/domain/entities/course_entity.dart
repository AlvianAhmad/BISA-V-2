class CourseEntity {
  final String image;
  final String title;
  final String lecturer;
  final int students;
  final double progress;

  const CourseEntity({
    required this.image,
    required this.title,
    required this.lecturer,
    required this.students,
    required this.progress,
  });
}
