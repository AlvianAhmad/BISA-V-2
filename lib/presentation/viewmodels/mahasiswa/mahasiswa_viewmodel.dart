//mahasiswa_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/datasources/mahasiswa_firestore_datasource.dart';

class MahasiswaViewModel
    extends
        ChangeNotifier {
  final MahasiswaFirestoreDatasource ds;

  MahasiswaViewModel(
    this.ds,
  );

  // ✅ Ambil UID user yang sedang login
  String get mahasiswaId {
    final user = FirebaseAuth.instance.currentUser;
    if (user ==
        null) {
      throw Exception(
        'User belum login. Silakan login dulu.',
      );
    }
    return user.uid;
  }

  // ================= JOIN KELAS =================
  Future<
    void
  >
  joinKelas(
    String kodeKelas,
  ) async {
    await ds.joinKelas(
      kodeKelas: kodeKelas,
      mahasiswaId: mahasiswaId,
    );

    final db = FirebaseFirestore.instance;
    final userRef = db
        .collection(
          'users',
        )
        .doc(
          mahasiswaId,
        );

    try {
      final userSnap = await userRef.get();
      final primary = userSnap.data()?['primaryKelasId'];

      if (primary ==
              null ||
          primary.toString().isEmpty) {
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

        if (kelasSnap.docs.isNotEmpty) {
          final kelasId = kelasSnap.docs.first.id;
          await userRef.set(
            {
              'primaryKelasId': kelasId,
            },
            SetOptions(
              merge: true,
            ),
          );
        }
      }
    } on FirebaseException catch (
      e
    ) {
      debugPrint(
        'WARN: gagal set primaryKelasId (${e.code}): ${e.message}',
      );
    } catch (
      e
    ) {
      debugPrint(
        'WARN: gagal set primaryKelasId: $e',
      );
    }
  }

  // ================= JOIN KELAS BY ID =================
  Future<
    void
  >
  joinKelasById(
    String kelasId,
  ) async {
    // 1) join by ID (ini yang utama)
    await ds.joinKelasById(
      kelasId: kelasId,
      mahasiswaId: mahasiswaId,
    );

    // 2) set primaryKelasId kalau belum ada (INI JANGAN bikin join dianggap gagal)
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db
          .collection(
            'users',
          )
          .doc(
            mahasiswaId,
          );

      final userSnap = await userRef.get();
      final primary = userSnap.data()?['primaryKelasId'];

      if (primary ==
              null ||
          primary.toString().isEmpty) {
        await userRef.set(
          {
            'primaryKelasId': kelasId,
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (
      e
    ) {
      // ✅ penting: join tetap dianggap sukses
      debugPrint(
        'SET PRIMARY FAILED (ignored): $e',
      );
    }
  }

  // ================= LEAVE / HAPUS KELAS DARI DAFTAR =================
  Future<
    void
  >
  hapusKelasDariDaftarById(
    String kelasId,
  ) async {
    // 1) hapus relasi join kelas
    await ds.hapusKelasDariDaftar(
      kelasId: kelasId,
      mahasiswaId: mahasiswaId,
    );

    // 2) OPTIONAL tapi penting:
    // kalau user punya primaryKelasId dan kebetulan sama dengan kelasId yang dihapus,
    // maka hapus field primaryKelasId supaya tidak nyangkut di fitur lain.
    final db = FirebaseFirestore.instance;
    final userRef = db
        .collection(
          'users',
        )
        .doc(
          mahasiswaId,
        );
    final userSnap = await userRef.get();

    final primary = userSnap.data()?['primaryKelasId']?.toString();
    if (primary !=
            null &&
        primary.isNotEmpty &&
        primary ==
            kelasId) {
      await userRef.set(
        {
          'primaryKelasId': FieldValue.delete(),
        },
        SetOptions(
          merge: true,
        ),
      );
    }
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
  kelasSaya() => ds.kelasSaya(
    mahasiswaId,
  );

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
  ) => ds.detailKelas(
    kelasId,
  );

  Stream<
    QuerySnapshot<
      Map<
        String,
        dynamic
      >
    >
  >
  semuaKelas() => ds.semuaKelas();

  // ================= MATERI =================
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
  ) => ds.materiByKelasId(
    kelasId,
  );

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
  ) => ds.materiByKelasNama(
    kelasNama,
  );

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
  ) => ds.materiByKelasField(
    kelasNama,
  );

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
  ) => ds.tugasByKelasNama(
    kelasNama,
  );

  Future<
    void
  >
  kumpulTugasLink({
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

  Future<
    bool
  >
  sudahKumpul(
    String tugasId,
  ) {
    return ds.sudahKumpul(
      tugasId,
      mahasiswaId,
    );
  }

  Future<
    Map<
      String,
      dynamic
    >?
  >
  detailPengumpulan(
    String tugasId,
  ) {
    return ds.detailPengumpulan(
      tugasId: tugasId,
      mahasiswaId: mahasiswaId,
    );
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
  ) => ds.jadwalByKelasNama(
    kelasNama,
  );

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
  ) => ds.absensiByKelasNama(
    kelasNama,
  );

  Future<
    void
  >
  absen(
    String absensiId,
  ) {
    return ds.absen(
      absensiId: absensiId,
      mahasiswaId: mahasiswaId,
    );
  }

  Future<
    bool
  >
  sudahAbsen(
    String absensiId,
  ) {
    return ds.sudahAbsen(
      absensiId: absensiId,
      mahasiswaId: mahasiswaId,
    );
  }
}
