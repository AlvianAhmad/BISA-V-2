// ========================= mahasiswa_viewmodel.dart =========================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/datasources/mahasiswa_firestore_datasource.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final MahasiswaFirestoreDatasource ds;

  MahasiswaViewModel(this.ds);

  /// TODO: ganti FirebaseAuth (uid)
  final String mahasiswaId = 'mhs_001';

  // ================= JOIN KELAS =================
  Future<void> joinKelas(String kodeKelas) async {
    await ds.joinKelas(kodeKelas: kodeKelas, mahasiswaId: mahasiswaId);
  }

  // ================= KELAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> kelasSaya() =>
      ds.kelasSaya(mahasiswaId);

  Stream<DocumentSnapshot<Map<String, dynamic>>> detailKelas(String kelasId) =>
      ds.detailKelas(kelasId);

  Stream<QuerySnapshot<Map<String, dynamic>>> semuaKelas() => ds.semuaKelas();

  // ================= MATERI =================
  Stream<QuerySnapshot<Map<String, dynamic>>> materi(String kelasId) =>
      ds.materi(kelasId);

  // ================= TUGAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> tugasByKelasNama(
    String kelasNama,
  ) => ds.tugasByKelasNama(kelasNama);

  Future<void> kumpulTugas(String tugasId) {
    return ds.kumpulTugas(tugasId: tugasId, mahasiswaId: mahasiswaId);
  }

  Future<bool> sudahKumpul(String tugasId) {
    return ds.sudahKumpul(tugasId: tugasId, mahasiswaId: mahasiswaId);
  }

  // ================= JADWAL =================
  Stream<QuerySnapshot<Map<String, dynamic>>> jadwalByKelasNama(
    String kelasNama,
  ) => ds.jadwalByKelasNama(kelasNama);

  // ================= ABSENSI =================
  // ✅ tetap pakai ini, tapi sekarang query firestore-nya tidak orderBy
  Stream<QuerySnapshot<Map<String, dynamic>>> absensiByKelasNama(
    String kelasNama,
  ) => ds.absensiByKelasNama(kelasNama);

  Future<void> absen(String absensiId) {
    return ds.absen(absensiId: absensiId, mahasiswaId: mahasiswaId);
  }

  Future<bool> sudahAbsen(String absensiId) {
    return ds.sudahAbsen(absensiId: absensiId, mahasiswaId: mahasiswaId);
  }
}
