import 'package:flutter/material.dart';
import '../../../data/datasources/mahasiswa_firestore_datasource.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final MahasiswaFirestoreDatasource ds;

  MahasiswaViewModel(this.ds);

  /// ⚠️ nanti ganti FirebaseAuth
  final String mahasiswaId = 'mhs_001';

  // JOIN KELAS
  Future<void> joinKelas(String kodeKelas) async {
    await ds.joinKelas(kodeKelas: kodeKelas, mahasiswaId: mahasiswaId);
  }

  // KELAS
  Stream kelasSaya() => ds.kelasSaya(mahasiswaId);
  Stream detailKelas(String kelasId) => ds.detailKelas(kelasId);

  // MATERI
  Stream materi(String kelasId) => ds.materi(kelasId);

  // TUGAS
  Stream tugas(String kelasId) => ds.tugas(kelasId);
  Future<void> kumpulTugas(String tugasId) =>
      ds.kumpulTugas(tugasId: tugasId, mahasiswaId: mahasiswaId);
  Future<bool> sudahKumpul(String tugasId) =>
      ds.sudahKumpul(tugasId: tugasId, mahasiswaId: mahasiswaId);

  // JADWAL
  Stream jadwal(String kelasId) => ds.jadwal(kelasId);

  // ABSENSI
  Stream absensi(String kelasId) => ds.absensi(kelasId);
  Future<void> absen(String absensiId) =>
      ds.absen(absensiId: absensiId, mahasiswaId: mahasiswaId);
  Future<bool> sudahAbsen(String absensiId) =>
      ds.sudahAbsen(absensiId: absensiId, mahasiswaId: mahasiswaId);
}
