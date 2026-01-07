import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/datasources/mahasiswa_firestore_datasource.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final MahasiswaFirestoreDatasource ds;

  MahasiswaViewModel(this.ds);

  // ✅ Ambil UID user yang sedang login
  String get mahasiswaId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User belum login. Silakan login dulu.');
    }
    return user.uid;
  }

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
  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasId(String kelasId) =>
      ds.materiByKelasId(kelasId);

  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasNama(
    String kelasNama,
  ) => ds.materiByKelasNama(kelasNama);

  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasField(
    String kelasNama,
  ) => ds.materiByKelasField(kelasNama);

  // ================= TUGAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> tugasByKelasNama(
    String kelasNama,
  ) => ds.tugasByKelasNama(kelasNama);

  Future<void> kumpulTugasLink({
    required String tugasId,
    required String url,
    String? catatan,
  }) async {
    await ds.kumpulTugas(
      tugasId: tugasId,
      mahasiswaId: mahasiswaId,
      url: url,
      catatan: catatan,
    );
  }

  Future<bool> sudahKumpul(String tugasId) {
    return ds.sudahKumpul(tugasId, mahasiswaId);
  }

  Future<Map<String, dynamic>?> detailPengumpulan(String tugasId) {
    return ds.detailPengumpulan(tugasId: tugasId, mahasiswaId: mahasiswaId);
  }

  // ================= JADWAL =================
  Stream<QuerySnapshot<Map<String, dynamic>>> jadwalByKelasNama(
    String kelasNama,
  ) => ds.jadwalByKelasNama(kelasNama);

  // ================= ABSENSI =================
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
