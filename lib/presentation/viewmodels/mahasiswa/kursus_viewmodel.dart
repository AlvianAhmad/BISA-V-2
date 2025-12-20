import 'package:flutter/material.dart';
import '../../../domain/entities/course_entity.dart';
import '../../../domain/usecases/add_courses_to_my_courses.dart';
import '../../../domain/usecases/get_available_courses.dart';
import '../../../domain/usecases/get_my_courses.dart';

class KursusViewModel
    extends
        ChangeNotifier {
  final GetMyCourses getMyCourses;
  final GetAvailableCourses getAvailableCourses;
  final AddCoursesToMyCourses addCoursesToMyCourses;

  KursusViewModel({
    required this.getMyCourses,
    required this.getAvailableCourses,
    required this.addCoursesToMyCourses,
  });

  final searchController = TextEditingController();
  String _query = '';

  bool isLoading = false;
  List<
    CourseEntity
  >
  _myCourses = [];
  List<
    CourseEntity
  >
  get myCourses => _myCourses;

  bool _disposed = false;

  List<
    CourseEntity
  >
  get filteredMyCourses {
    if (_query.trim().isEmpty) return _myCourses;
    final q = _query.toLowerCase();
    return _myCourses.where(
      (
        c,
      ) {
        return c.title.toLowerCase().contains(
              q,
            ) ||
            c.lecturer.toLowerCase().contains(
              q,
            );
      },
    ).toList();
  }

  void onSearchChanged(
    String v,
  ) {
    _query = v;
    if (!_disposed) notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _query = '';
    if (!_disposed) notifyListeners();
  }

  Future<
    void
  >
  init() async {
    isLoading = true;
    if (!_disposed) notifyListeners();

    _myCourses = await getMyCourses();

    isLoading = false;
    if (!_disposed) notifyListeners();
  }

  Future<
    List<
      CourseEntity
    >
  >
  loadAvailableCourses() async {
    return getAvailableCourses();
  }

  Future<
    void
  >
  enrollCourses(
    List<
      CourseEntity
    >
    selected,
  ) async {
    await addCoursesToMyCourses(
      selected,
    );
    _myCourses = await getMyCourses();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    super.dispose();
  }
}
