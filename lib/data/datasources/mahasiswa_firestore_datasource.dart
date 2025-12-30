import 'package:cloud_firestore/cloud_firestore.dart';

class MahasiswaFirestoreDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= JOIN KELAS =================
  Future<void> joinKelas({
    required String kodeKelas,
    required String mahasiswaId,
  }) async {
    final kelasSnap = await _db
        .collection('kelas')
        .where('kode', isEqualTo: kodeKelas)
        .limit(1)
        .get();

    if (kelasSnap.docs.isEmpty) {
      throw Exception('Kode kelas tidak ditemukan');
    }

    final kelasId = kelasSnap.docs.first.id;

    await _db.collection('mahasiswa_kelas').doc('$mahasiswaId-$kelasId').set({
      'mahasiswaId': mahasiswaId,
      'kelasId': kelasId,
      'joinedAt': Timestamp.now(),
    });
  }

  // ================= KELAS =================
  Stream<QuerySnapshot> kelasSaya(String mahasiswaId) {
    return _db
        .collection('mahasiswa_kelas')
        .where('mahasiswaId', isEqualTo: mahasiswaId)
        .snapshots();
  }

  Stream<DocumentSnapshot> detailKelas(String kelasId) {
    return _db.collection('kelas').doc(kelasId).snapshots();
  }

  // ================= MATERI =================
  Stream<QuerySnapshot> materi(String kelasId) {
    return _db
        .collection('materi')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  // ================= TUGAS =================
  Stream<QuerySnapshot> tugas(String kelasId) {
    return _db
        .collection('tugas')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  Future<void> kumpulTugas({
    required String tugasId,
    required String mahasiswaId,
  }) async {
    await _db
        .collection('tugas')
        .doc(tugasId)
        .collection('pengumpulan')
        .doc(mahasiswaId)
        .set({'mahasiswaId': mahasiswaId, 'waktu': Timestamp.now()});
  }

  Future<bool> sudahKumpul({
    required String tugasId,
    required String mahasiswaId,
  }) async {
    final doc = await _db
        .collection('tugas')
        .doc(tugasId)
        .collection('pengumpulan')
        .doc(mahasiswaId)
        .get();

    return doc.exists;
  }

  // ================= JADWAL =================
  Stream<QuerySnapshot> jadwal(String kelasId) {
    return _db
        .collection('jadwal')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  // ================= ABSENSI =================
  Stream<QuerySnapshot> absensi(String kelasId) {
    return _db
        .collection('absensi')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  Future<void> absen({
    required String absensiId,
    required String mahasiswaId,
  }) async {
    await _db
        .collection('absensi')
        .doc(absensiId)
        .collection('hadir')
        .doc(mahasiswaId)
        .set({'mahasiswaId': mahasiswaId, 'waktu': Timestamp.now()});
  }

  Future<bool> sudahAbsen({
    required String absensiId,
    required String mahasiswaId,
  }) async {
    final doc = await _db
        .collection('absensi')
        .doc(absensiId)
        .collection('hadir')
        .doc(mahasiswaId)
        .get();

    return doc.exists;
  }
}
