import 'package:cloud_firestore/cloud_firestore.dart';

class MahasiswaFirestoreDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= JOIN KELAS =================
  Future<void> joinKelas({
    required String kodeKelas,
    required String mahasiswaId,
  }) async {
    // cari kelas berdasarkan kode
    final kelasSnap = await _db
        .collection('kelas')
        .where('kode', isEqualTo: kodeKelas)
        .limit(1)
        .get();

    if (kelasSnap.docs.isEmpty) {
      throw Exception('Kode kelas tidak ditemukan');
    }

    final kelasId = kelasSnap.docs.first.id;
    final docId = '$mahasiswaId-$kelasId';

    // cegah join dobel
    final existing = await _db.collection('kelas').doc(docId).get();

    if (existing.exists) return;

    await _db.collection('kelas').doc(docId).set({
      'mahasiswaId': mahasiswaId,
      'kelasId': kelasId,
      'joinedAt': Timestamp.now(),
    });
  }

  // ================= KELAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> kelasSaya(String mahasiswaId) {
    return _db
        .collection('kelas')
        .where('mahasiswaId', isEqualTo: mahasiswaId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> detailKelas(String kelasId) {
    return _db.collection('kelas').doc(kelasId).snapshots();
  }

  // ================= MATERI =================
  Stream<QuerySnapshot<Map<String, dynamic>>> materi(String kelasId) {
    return _db
        .collection('materi')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  // ================= TUGAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> tugas(String kelasId) {
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
        .set({
          'mahasiswaId': mahasiswaId,
          'submittedAt': Timestamp.now(),
          'status': 'submitted',
        });
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
  Stream<QuerySnapshot<Map<String, dynamic>>> jadwal(String kelasId) {
    return _db
        .collection('jadwal')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }

  // ================= ABSENSI =================
  Stream<QuerySnapshot<Map<String, dynamic>>> absensi(String kelasId) {
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
        .set({
          'mahasiswaId': mahasiswaId,
          'hadir': true,
          'waktu': Timestamp.now(),
        });
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
