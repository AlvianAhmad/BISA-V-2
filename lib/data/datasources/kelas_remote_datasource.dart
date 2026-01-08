// lib/data/datasources/kelas_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/kelas.dart';

class KelasRemoteDataSource {
  final FirebaseFirestore firestore;

  KelasRemoteDataSource(
    this.firestore,
  );

  Stream<
    List<
      Kelas
    >
  >
  getKelas() {
    return firestore
        .collection(
          'kelas',
        )
        .snapshots()
        .map(
          (
            snapshot,
          ) {
            return snapshot.docs.map(
              (
                doc,
              ) {
                final d = doc.data();

                return Kelas(
                  id: doc.id,
                  nama:
                      (d['nama'] ??
                              '')
                          .toString(),
                  jurusan:
                      (d['jurusan'] ??
                              '')
                          .toString(),
                  semester:
                      (d['semester'] ??
                              '')
                          .toString(),
                  dosen:
                      (d['dosen'] ??
                              '')
                          .toString(), // ✅ ambil dosen
                );
              },
            ).toList();
          },
        );
  }

  Future<
    void
  >
  addKelas(
    Kelas kelas,
  ) async {
    await firestore
        .collection(
          'kelas',
        )
        .add(
          {
            'nama': kelas.nama.trim(),
            'jurusan': kelas.jurusan.trim(),
            'semester': kelas.semester.trim(),
            'dosen': kelas.dosen.trim(), // ✅ simpan dosen
            'createdAt': Timestamp.now(),
          },
        );
  }

  Future<
    void
  >
  updateKelas(
    Kelas kelas,
  ) async {
    await firestore
        .collection(
          'kelas',
        )
        .doc(
          kelas.id,
        )
        .update(
          {
            'nama': kelas.nama.trim(),
            'jurusan': kelas.jurusan.trim(),
            'semester': kelas.semester.trim(),
            'dosen': kelas.dosen.trim(), // ✅ update dosen
            'updatedAt': Timestamp.now(),
          },
        );
  }

  Future<
    void
  >
  deleteKelas(
    String id,
  ) async {
    final kelasRef = firestore
        .collection(
          'kelas',
        )
        .doc(
          id,
        );

    // Ambil semua relasi mahasiswa yang join kelas ini
    final relSnap = await firestore
        .collection(
          'kelas_mahasiswa',
        )
        .where(
          'kelasId',
          isEqualTo: id,
        )
        .get();

    final batch = firestore.batch();

    // Hapus semua relasi join
    for (final doc in relSnap.docs) {
      batch.delete(
        doc.reference,
      );
    }

    // Hapus kelasnya
    batch.delete(
      kelasRef,
    );

    await batch.commit();
  }
}
