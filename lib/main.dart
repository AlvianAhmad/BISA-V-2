import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'routes/app_router.dart';
import 'routes/app_routes.dart';

// ===== AUTH =====
import 'data/datasources/auth_firebase_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';

import 'presentation/viewmodels/auth/auth_viewmodel.dart';
import 'presentation/viewmodels/admin/admin_viewmodel.dart';
import 'presentation/viewmodels/auth/login_viewmodel.dart';
import 'presentation/viewmodels/auth/register_viewmodel.dart';

// ===== COURSE (KURSUS) =====
import 'data/datasources/course_local_datasource.dart';
import 'data/repositories/course_repository_impl.dart';

import 'domain/usecases/get_my_courses.dart';
import 'domain/usecases/get_available_courses.dart';
import 'domain/usecases/add_courses_to_my_courses.dart';

import 'presentation/viewmodels/mahasiswa/kursus_viewmodel.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<
    MyApp
  >
  createState() => _MyAppState();
}

class _MyAppState
    extends
        State<
          MyApp
        > {
  late final AuthRepositoryImpl _authRepository;

  late final CourseRepositoryImpl _courseRepository;
  late final GetMyCourses _getMyCourses;
  late final GetAvailableCourses _getAvailableCourses;
  late final AddCoursesToMyCourses _addCoursesToMyCourses;

  @override
  void initState() {
    super.initState();

    // ===== AUTH =====
    _authRepository = AuthRepositoryImpl(
      AuthFirebaseDatasource(),
    );

    // ===== COURSE =====
    _courseRepository = CourseRepositoryImpl(
      CourseLocalDataSource(),
    );

    _getMyCourses = GetMyCourses(
      _courseRepository,
    );
    _getAvailableCourses = GetAvailableCourses(
      _courseRepository,
    );
    _addCoursesToMyCourses = AddCoursesToMyCourses(
      _courseRepository,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MultiProvider(
      providers: [
        // ===== AUTH =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => AuthViewModel(
                _authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => AdminViewModel(
                _authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => LoginViewModel(
                _authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => RegisterViewModel(
                _authRepository,
              ),
        ),

        // ===== KURSUS =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => KursusViewModel(
                getMyCourses: _getMyCourses,
                getAvailableCourses: _getAvailableCourses,
                addCoursesToMyCourses: _addCoursesToMyCourses,
              )..init(), // ✅ auto load my courses
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.authGate,

        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
