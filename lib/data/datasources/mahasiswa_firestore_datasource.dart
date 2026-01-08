//mahasiswa_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MahasiswaFirestoreDatasource {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ================= JOIN KELAS =================
  Future<
    void
  >
  joinKelas({
    required String kodeKelas,
    required String mahasiswaId,
  }) async {
    final kelasSnap = await db
        .collection(
          'kelas',
        )
        .where(
          'kode',
          isEqualTo: kodeKelas,
        )
        .limit(
          1,
        )
        .get();

    if (kelasSnap.docs.isEmpty) {
      throw Exception(
        'Kode kelas tidak ditemukan',
      );
    }

    final kelasId = kelasSnap.docs.first.id;
    final docId = '$mahasiswaId-$kelasId';

    final existing = await db
        .collection(
          'kelas_mahasiswa',
        )
        .doc(
          docId,
        )
        .get();
    if (existing.exists) return;

    await db
        .collection(
          'kelas_mahasiswa',
        )
        .doc(
          docId,
        )
        .set(
          {
            'mahasiswaId': mahasiswaId,
            'kelasId': kelasId,
            'joinedAt': FieldValue.serverTimestamp(),
          },
        );
  }

  // ================= JOIN KELAS BY ID =================
  Future<
    void
  >
  joinKelasById({
    required String kelasId,
    required String mahasiswaId,
  }) async {
    // pastikan kelasnya ada
    final kelasDoc = await db
        .collection(
          'kelas',
        )
        .doc(
          kelasId,
        )
        .get();
    if (!kelasDoc.exists) {
      throw Exception(
        'Kelas tidak ditemukan.',
      );
    }

    final docId = '$mahasiswaId-$kelasId';

    final existing = await db
        .collection(
          'kelas_mahasiswa',
        )
        .doc(
          docId,
        )
        .get();
    if (existing.exists) return;

    await db
        .collection(
          'kelas_mahasiswa',
        )
        .doc(
          docId,
        )
        .set(
          {
            'mahasiswaId': mahasiswaId,
            'kelasId': kelasId,
            'joinedAt': FieldValue.serverTimestamp(),
          },
        );
  }

  // ================= LEAVE / HAPUS KELAS DARI DAFTAR =================
  Future<
    void
  >
  hapusKelasDariDaftar({
    required String kelasId,
    required String mahasiswaId,
  }) async {
    final docId = '$mahasiswaId-$kelasId';

    await db
        .collection(
          'kelas_mahasiswa',
        )
        .doc(
          docId,
        )
        .delete();
  }

  // ================= KELAS =================
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  kelasSaya(
    String mahasiswaId,
  ) {
    return db
        .collection(
          'kelas_mahasiswa',
        )
        .where(
          'mahasiswaId',
          isEqualTo: mahasiswaId,
        )
        .snapshots();
  }

  Stream<
    DocumentSnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  detailKelas(
    String kelasId,
  ) {
    return db
        .collection(
          'kelas',
        )
        .doc(
          kelasId,
        )
        .snapshots();
  }

  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  semuaKelas() {
    // kalau error index, hapus orderBy
    return db
        .collection(
          'kelas',
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ================= MATERI =================
  // Query by kelasId (kalau materi memang punya field kelasId)
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  materiByKelasId(
    String kelasId,
  ) {
    // kalau error index, hapus orderBy
    return db
        .collection(
          'materi',
        )
        .where(
          'kelasId',
          isEqualTo: kelasId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // Query by kelasNama (kalau materi admin simpan kelasNama)
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  materiByKelasNama(
    String kelasNama,
  ) {
    // kalau error index, hapus orderBy
    return db
        .collection(
          'materi',
        )
        .where(
          'kelasNama',
          isEqualTo: kelasNama,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // Query by kelas (kalau materi admin simpan field "kelas")
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  materiByKelasField(
    String kelasNama,
  ) {
    // kalau error index, hapus orderBy
    return db
        .collection(
          'materi',
        )
        .where(
          'kelas',
          isEqualTo: kelasNama,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ================= TUGAS =================
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  tugasByKelasNama(
    String kelasNama,
  ) {
    return db
        .collection(
          'tugas',
        )
        .where(
          'kelas',
          isEqualTo: kelasNama,
        )
        .snapshots();
  }

  /// ✅ UPDATED: sekarang simpan juga nama + nim ke pengumpulan
  Future<
    void
  >
  kumpulTugas({
    required String tugasId,
    required String mahasiswaId,
    required String url,
    String? catatan,
  }) async {
    // ambil profil mahasiswa dari users/{uid}
    final userSnap = await db
        .collection(
          'users',
        )
        .doc(
          mahasiswaId,
        )
        .get();
    final u =
        userSnap.data() ??
        {};

    final nama =
        (u['nama'] ??
                u['name'] ??
                u['fullname'] ??
                '-')
            .toString();
    final nim =
        (u['nim'] ??
                u['NIM'] ??
                '-')
            .toString();

    final ref = db
        .collection(
          'tugas',
        )
        .doc(
          tugasId,
        )
        .collection(
          'pengumpulan',
        )
        .doc(
          mahasiswaId,
        );

    await ref.set(
      {
        'mahasiswaId': mahasiswaId,

        // ✅ tambahan biar admin bisa lihat nama + nim
        'nama': nama,
        'nim': nim,

        'url': url.trim(),
        'catatan':
            (catatan ??
                    '')
                .trim(),

        // biar aman, simpan waktu submit & update
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<
    bool
  >
  sudahKumpul(
    String tugasId,
    String mahasiswaId,
  ) async {
    final doc = await db
        .collection(
          'tugas',
        )
        .doc(
          tugasId,
        )
        .collection(
          'pengumpulan',
        )
        .doc(
          mahasiswaId,
        )
        .get();

    return doc.exists;
  }

  Future<
    Map<
      String,
      dynamic
    >?
  >
  detailPengumpulan({
    required String tugasId,
    required String mahasiswaId,
  }) async {
    final doc = await db
        .collection(
          'tugas',
        )
        .doc(
          tugasId,
        )
        .collection(
          'pengumpulan',
        )
        .doc(
          mahasiswaId,
        )
        .get();

    return doc.data();
  }

  // ================= JADWAL =================
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  jadwalByKelasNama(
    String kelasNama,
  ) {
    return db
        .collection(
          'jadwal',
        )
        .where(
          'kelas',
          isEqualTo: kelasNama,
        )
        .snapshots();
  }

  // ================= ABSENSI =================
  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  absensiByKelasNama(
    String kelasNama,
  ) {
    // (tanpa orderBy supaya gak butuh composite index)
    return db
        .collection(
          'absensi',
        )
        .where(
          'kelas',
          isEqualTo: kelasNama,
        )
        .snapshots();
  }

  Future<
    void
  >
  absen({
    required String absensiId,
    required String mahasiswaId,
  }) async {
    // ambil profil mahasiswa dari users/{uid}
    final userSnap = await db
        .collection(
          'users',
        )
        .doc(
          mahasiswaId,
        )
        .get();
    final u =
        userSnap.data() ??
        {};

    final nama =
        (u['nama'] ??
                u['name'] ??
                u['fullname'] ??
                '-')
            .toString();
    final nim =
        (u['nim'] ??
                u['npm'] ??
                u['NIM'] ??
                u['NPM'] ??
                '-')
            .toString();

    await db
        .collection(
          'absensi',
        )
        .doc(
          absensiId,
        )
        .collection(
          'hadir',
        )
        .doc(
          mahasiswaId,
        )
        .set(
          {
            'mahasiswaId': mahasiswaId,
            'hadir': true,

            // ✅ tambahan biar admin/dosen bisa lihat
            'nama': nama,
            'nim': nim, // atau npm, tapi kita samakan pakai nim aja

            'waktu': FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
  }

  Future<
    bool
  >
  sudahAbsen({
    required String absensiId,
    required String mahasiswaId,
  }) async {
    final doc = await db
        .collection(
          'absensi',
        )
        .doc(
          absensiId,
        )
        .collection(
          'hadir',
        )
        .doc(
          mahasiswaId,
        )
        .get();

    return doc.exists;
  }
}
