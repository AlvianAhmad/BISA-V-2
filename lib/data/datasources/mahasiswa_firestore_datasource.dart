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
    final docId = '$mahasiswaId-$kelasId';

    final existing = await _db.collection('kelas_mahasiswa').doc(docId).get();
    if (existing.exists) return;

    await _db.collection('kelas_mahasiswa').doc(docId).set({
      'mahasiswaId': mahasiswaId,
      'kelasId': kelasId,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= KELAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> kelasSaya(String mahasiswaId) {
    return _db
        .collection('kelas_mahasiswa')
        .where('mahasiswaId', isEqualTo: mahasiswaId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> detailKelas(String kelasId) {
    return _db.collection('kelas').doc(kelasId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> semuaKelas() {
    // kalau error index, hapus orderBy
    return _db
        .collection('kelas')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ================= MATERI =================
  // Query by kelasId (kalau materi memang punya field kelasId)
  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasId(String kelasId) {
    // kalau error index, hapus orderBy
    return _db
        .collection('materi')
        .where('kelasId', isEqualTo: kelasId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Query by kelasNama (kalau materi admin simpan kelasNama)
  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasNama(
    String kelasNama,
  ) {
    // kalau error index, hapus orderBy
    return _db
        .collection('materi')
        .where('kelasNama', isEqualTo: kelasNama)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Query by kelas (kalau materi admin simpan field "kelas")
  Stream<QuerySnapshot<Map<String, dynamic>>> materiByKelasField(
    String kelasNama,
  ) {
    // kalau error index, hapus orderBy
    return _db
        .collection('materi')
        .where('kelas', isEqualTo: kelasNama)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ================= TUGAS =================
  Stream<QuerySnapshot<Map<String, dynamic>>> tugasByKelasNama(
    String kelasNama,
  ) {
    return _db
        .collection('tugas')
        .where('kelas', isEqualTo: kelasNama)
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
          'submittedAt': FieldValue.serverTimestamp(),
          'status': 'submitted',
        }, SetOptions(merge: true));
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
  Stream<QuerySnapshot<Map<String, dynamic>>> jadwalByKelasNama(
    String kelasNama,
  ) {
    return _db
        .collection('jadwal')
        .where('kelas', isEqualTo: kelasNama)
        .snapshots();
  }

  // ================= ABSENSI =================
  Stream<QuerySnapshot<Map<String, dynamic>>> absensiByKelasNama(
    String kelasNama,
  ) {
    // (tanpa orderBy supaya gak butuh composite index)
    return _db
        .collection('absensi')
        .where('kelas', isEqualTo: kelasNama)
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
          'waktu': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
