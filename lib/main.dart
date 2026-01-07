import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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

// ===== MAHASISWA (kelas, join, tugas, absensi, dll yang kamu masih pakai) =====
import 'data/datasources/mahasiswa_firestore_datasource.dart';
import 'presentation/viewmodels/mahasiswa/mahasiswa_viewmodel.dart';

// ===== MATERI REMOTE DATASOURCE (DIPAKAI MAHASISWA) =====
import 'data/datasources/materi_remote_datasource.dart';
// ✅ ViewModel materi mahasiswa (yang aku buat sebelumnya) -> pakai alias biar ga bentrok
import 'presentation/viewmodels/mahasiswa/materi_viewmodel.dart' as mhs_materi;

// ===== JADWAL (ADMIN) =====
import 'data/datasources/jadwal_remote_datasource.dart';
import 'data/repositories/jadwal_repository_impl.dart';
import 'domain/usecases/jadwal/get_jadwal.dart';
import 'domain/usecases/jadwal/add_jadwal.dart';
import 'domain/usecases/jadwal/update_jadwal.dart';
import 'domain/usecases/jadwal/delete_jadwal.dart';
import 'presentation/viewmodels/admin/jadwal/jadwal_view_model.dart';

// ===== KELAS (ADMIN) =====
import 'data/datasources/kelas_remote_datasource.dart';
import 'data/repositories/kelas_repository_impl.dart';
import 'domain/usecases/kelas/get_kelas.dart';
import 'domain/usecases/kelas/add_kelas.dart';
import 'domain/usecases/kelas/update_kelas.dart';
import 'domain/usecases/kelas/delete_kelas.dart';
import 'presentation/viewmodels/admin/kelas/kelas_view_model.dart';

// ===== TUGAS (ADMIN) =====
import 'data/datasources/tugas_remote_datasource.dart';
import 'data/repositories/tugas_repository_impl.dart';
import 'domain/usecases/tugas/get_tugas.dart';
import 'domain/usecases/tugas/add_tugas.dart';
import 'domain/usecases/tugas/update_tugas.dart';
import 'domain/usecases/tugas/delete_tugas.dart';
import 'presentation/viewmodels/admin/tugas/tugas_view_model.dart';

// ===== ABSENSI (ADMIN) =====
import 'data/datasources/absensi_remote_datasource.dart';
import 'data/repositories/absensi_repository_impl.dart';
import 'domain/usecases/absensi/get_absensi.dart';
import 'domain/usecases/absensi/add_absensi.dart';
import 'domain/usecases/absensi/update_absensi.dart';
import 'domain/usecases/absensi/delete_absensi.dart';
import 'presentation/viewmodels/admin/absensi/absensi_view_model.dart';

// ===== MATERI (ADMIN) =====
import 'data/repositories/materi_repository_impl.dart';
import 'domain/usecases/materi/get_materi.dart';
import 'domain/usecases/materi/add_materi.dart';
import 'domain/usecases/materi/update_materi.dart';
import 'domain/usecases/materi/delete_materi.dart';
import 'presentation/viewmodels/admin/materi/materi_view_model.dart';

Future<
  void
>
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting(
    'id_ID',
    null,
  );
  Intl.defaultLocale = 'id_ID';

  runApp(
    const MyApp(),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // ===== AUTH =====
    final authRepository = AuthRepositoryImpl(
      AuthFirebaseDatasource(),
    );

    // ===== MAHASISWA =====
    final mahasiswaDatasource = MahasiswaFirestoreDatasource();

    // ===== ADMIN REPOSITORIES =====
    final jadwalRepository = JadwalRepositoryImpl(
      JadwalRemoteDataSource(
        FirebaseFirestore.instance,
      ),
    );

    final kelasRepository = KelasRepositoryImpl(
      KelasRemoteDataSource(
        FirebaseFirestore.instance,
      ),
    );

    final tugasRepository = TugasRepositoryImpl(
      TugasRemoteDataSource(
        FirebaseFirestore.instance,
      ),
    );

    final absensiRepository = AbsensiRepositoryImpl(
      AbsensiRemoteDatasource(
        FirebaseFirestore.instance,
      ),
    );

    final materiRepository = MateriRepositoryImpl(
      MateriRemoteDatasource(
        FirebaseFirestore.instance,
      ),
    );

    // ===== MATERI REMOTE (UNTUK MAHASISWA) =====
    final materiRemoteDs = MateriRemoteDatasource(
      FirebaseFirestore.instance,
    );

    return MultiProvider(
      providers: [
        // ===== AUTH =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => AuthViewModel(
                authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => AdminViewModel(
                authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => LoginViewModel(
                authRepository,
              ),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => RegisterViewModel(
                authRepository,
              ),
        ),

        // ===== MAHASISWA (GLOBAL) =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => MahasiswaViewModel(
                mahasiswaDatasource,
              ),
        ),

        // ✅ ===== MATERI MAHASISWA (BARU, PAKAI RemoteDatasource) =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => mhs_materi.MateriViewModel(
                materiRemoteDs,
              ),
        ),

        // ===== ADMIN JADWAL =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => JadwalViewModel(
                getJadwal: GetJadwal(
                  jadwalRepository,
                ),
                addJadwal: AddJadwal(
                  jadwalRepository,
                ),
                updateJadwal: UpdateJadwal(
                  jadwalRepository,
                ),
                deleteJadwal: DeleteJadwal(
                  jadwalRepository,
                ),
              ),
        ),

        // ===== ADMIN KELAS =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => KelasViewModel(
                getKelas: GetKelas(
                  kelasRepository,
                ),
                addKelas: AddKelas(
                  kelasRepository,
                ),
                updateKelas: UpdateKelas(
                  kelasRepository,
                ),
                deleteKelas: DeleteKelas(
                  kelasRepository,
                ),
              ),
        ),

        // ===== ADMIN TUGAS =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => TugasViewModel(
                getTugas: GetTugas(
                  tugasRepository,
                ),
                addTugas: AddTugas(
                  tugasRepository,
                ),
                updateTugas: UpdateTugas(
                  tugasRepository,
                ),
                deleteTugas: DeleteTugas(
                  tugasRepository,
                ),
              ),
        ),

        // ===== ADMIN ABSENSI =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => AbsensiViewModel(
                getAbsensi: GetAbsensi(
                  absensiRepository,
                ),
                addAbsensi: AddAbsensi(
                  absensiRepository,
                ),
                updateAbsensi: UpdateAbsensi(
                  absensiRepository,
                ),
                deleteAbsensi: DeleteAbsensi(
                  absensiRepository,
                ),
              ),
        ),

        // ===== ADMIN MATERI =====
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => MateriViewModel(
                getMateri: GetMateri(
                  materiRepository,
                ),
                addMateri: AddMateri(
                  materiRepository,
                ),
                updateMateri: UpdateMateri(
                  materiRepository,
                ),
                deleteMateri: DeleteMateri(
                  materiRepository,
                ),
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
