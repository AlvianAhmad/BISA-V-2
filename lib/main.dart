import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

// ===== COURSE =====
import 'data/datasources/course_local_datasource.dart';
import 'data/repositories/course_repository_impl.dart';
import 'domain/usecases/get_my_courses.dart';
import 'domain/usecases/get_available_courses.dart';
import 'domain/usecases/add_courses_to_my_courses.dart';

// ===== JADWAL =====
import 'data/datasources/jadwal_remote_datasource.dart';
import 'data/repositories/jadwal_repository_impl.dart';
import 'domain/usecases/jadwal/get_jadwal.dart';
import 'domain/usecases/jadwal/add_jadwal.dart';
import 'domain/usecases/jadwal/update_jadwal.dart';
import 'domain/usecases/jadwal/delete_jadwal.dart';
import 'presentation/viewmodels/admin/jadwal/jadwal_view_model.dart';

// ===== KELAS =====
import 'data/datasources/kelas_remote_datasource.dart';
import 'data/repositories/kelas_repository_impl.dart';
import 'domain/usecases/kelas/get_kelas.dart';
import 'domain/usecases/kelas/add_kelas.dart';
import 'domain/usecases/kelas/update_kelas.dart';
import 'domain/usecases/kelas/delete_kelas.dart';
import 'presentation/viewmodels/admin/kelas/kelas_view_model.dart';

// ===== TUGAS =====
import 'data/datasources/tugas_remote_datasource.dart';
import 'data/repositories/tugas_repository_impl.dart';
import 'domain/usecases/tugas/get_tugas.dart';
import 'domain/usecases/tugas/add_tugas.dart';
import 'domain/usecases/tugas/update_tugas.dart';
import 'domain/usecases/tugas/delete_tugas.dart';
import 'presentation/viewmodels/admin/tugas/tugas_view_model.dart';

// ===== ABSENSI =====
import 'data/datasources/absensi_remote_datasource.dart';
import 'data/repositories/absensi_repository_impl.dart';
import 'domain/usecases/absensi/add_absensi.dart';
import 'domain/usecases/absensi/get_absensi.dart';
import 'domain/usecases/absensi/update_absensi.dart';
import 'domain/usecases/absensi/delete_absensi.dart';
import 'presentation/viewmodels/admin/absensi/absensi_view_model.dart';

// ===== MATERI =====
import 'data/datasources/materi_remote_datasource.dart';
import 'data/repositories/materi_repository_impl.dart';
import 'domain/usecases/materi/get_materi.dart';
import 'domain/usecases/materi/add_materi.dart';
import 'domain/usecases/materi/update_materi.dart';
import 'domain/usecases/materi/delete_materi.dart';
import 'presentation/viewmodels/admin/materi/materi_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== AUTH =====
    final authRepository = AuthRepositoryImpl(AuthFirebaseDatasource());

    // ===== COURSE =====
    final courseRepository = CourseRepositoryImpl(CourseLocalDataSource());
    final getMyCourses = GetMyCourses(courseRepository);
    final getAvailableCourses = GetAvailableCourses(courseRepository);
    final addCoursesToMyCourses = AddCoursesToMyCourses(courseRepository);

    // ===== JADWAL =====
    final jadwalRepository = JadwalRepositoryImpl(
      JadwalRemoteDataSource(FirebaseFirestore.instance),
    );
    final getJadwal = GetJadwal(jadwalRepository);
    final addJadwal = AddJadwal(jadwalRepository);
    final updateJadwal = UpdateJadwal(jadwalRepository);
    final deleteJadwal = DeleteJadwal(jadwalRepository);

    // ===== KELAS =====
    final kelasRepository = KelasRepositoryImpl(
      KelasRemoteDataSource(FirebaseFirestore.instance),
    );
    final getKelas = GetKelas(kelasRepository);
    final addKelas = AddKelas(kelasRepository);
    final updateKelas = UpdateKelas(kelasRepository);
    final deleteKelas = DeleteKelas(kelasRepository);

    // ===== TUGAS =====
    final tugasRepository = TugasRepositoryImpl(
      TugasRemoteDataSource(FirebaseFirestore.instance),
    );
    final getTugas = GetTugas(tugasRepository);
    final addTugas = AddTugas(tugasRepository);
    final updateTugas = UpdateTugas(tugasRepository);
    final deleteTugas = DeleteTugas(tugasRepository);

    // ===== ABSENSI =====
    final absensiRepository = AbsensiRepositoryImpl(
      AbsensiRemoteDatasource(FirebaseFirestore.instance),
    );
    final getAbsensi = GetAbsensi(absensiRepository);
    final addAbsensi = AddAbsensi(absensiRepository);
    final updateAbsensi = UpdateAbsensi(absensiRepository);
    final deleteAbsensi = DeleteAbsensi(absensiRepository);

    // ===== MATERI =====
    final materiRepository = MateriRepositoryImpl(
      MateriRemoteDatasource(FirebaseFirestore.instance),
    );
    final getMateri = GetMateri(materiRepository);
    final addMateri = AddMateri(materiRepository);
    final updateMateri = UpdateMateri(materiRepository);
    final deleteMateri = DeleteMateri(materiRepository);

    return MultiProvider(
      providers: [
        // ===== AUTH =====
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => AdminViewModel(authRepository)),
        ChangeNotifierProvider(create: (_) => LoginViewModel(authRepository)),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(authRepository),
        ),

        // ===== JADWAL =====
        ChangeNotifierProvider(
          create: (_) => JadwalViewModel(
            getJadwal: getJadwal,
            addJadwal: addJadwal,
            updateJadwal: updateJadwal,
            deleteJadwal: deleteJadwal,
          ),
        ),

        // ===== KELAS =====
        ChangeNotifierProvider(
          create: (_) => KelasViewModel(
            getKelas: getKelas,
            addKelas: addKelas,
            updateKelas: updateKelas,
            deleteKelas: deleteKelas,
          ),
        ),

        // ===== TUGAS =====
        ChangeNotifierProvider(
          create: (_) => TugasViewModel(
            getTugas: getTugas,
            addTugas: addTugas,
            updateTugas: updateTugas,
            deleteTugas: deleteTugas,
          ),
        ),

        // ===== ABSENSI =====
        ChangeNotifierProvider(
          create: (_) => AbsensiViewModel(
            getAbsensi: getAbsensi,
            addAbsensi: addAbsensi,
            updateAbsensi: updateAbsensi,
            deleteAbsensi: deleteAbsensi,
          ),
        ),

        // ===== MATERI =====
        ChangeNotifierProvider(
          create: (_) => MateriViewModel(
            getMateri: getMateri,
            addMateri: addMateri,
            updateMateri: updateMateri,
            deleteMateri: deleteMateri,
          ),
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
