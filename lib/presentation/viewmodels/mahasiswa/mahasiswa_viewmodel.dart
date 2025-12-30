import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ INI YANG KURANG
import '../../../data/datasources/mahasiswa_firestore_datasource.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final MahasiswaFirestoreDatasource ds;

  MahasiswaViewModel(this.ds);

  /// ⚠️ nanti ganti FirebaseAuth
  final String mahasiswaId = 'mhs_001';

  // ================= JOIN KELAS =================
  Future<void> joinKelas(String kodeKelas) async {
    await ds.joinKelas(kodeKelas: kodeKelas, mahasiswaId: mahasiswaId);
  }

  // ================= KELAS =================
  Stream<QuerySnapshot> kelasSaya() => ds.kelasSaya(mahasiswaId);

  Stream<DocumentSnapshot> detailKelas(String kelasId) =>
      ds.detailKelas(kelasId);

  // ================= MATERI =================
  Stream<QuerySnapshot> materi(String kelasId) => ds.materi(kelasId);

  // ================= TUGAS =================
  Stream<QuerySnapshot> tugas(String kelasId) => ds.tugas(kelasId);

  Future<void> kumpulTugas(String tugasId) {
    return ds.kumpulTugas(tugasId: tugasId, mahasiswaId: mahasiswaId);
  }

  Future<bool> sudahKumpul(String tugasId) {
    return ds.sudahKumpul(tugasId: tugasId, mahasiswaId: mahasiswaId);
  }

  // ================= JADWAL =================
  Stream<QuerySnapshot> jadwal(String kelasId) => ds.jadwal(kelasId);

  // ================= ABSENSI =================
  Stream<QuerySnapshot> absensi(String kelasId) => ds.absensi(kelasId);

  Future<void> absen(String absensiId) {
    return ds.absen(absensiId: absensiId, mahasiswaId: mahasiswaId);
  }

  Future<bool> sudahAbsen(String absensiId) {
    return ds.sudahAbsen(absensiId: absensiId, mahasiswaId: mahasiswaId);
  }
}
