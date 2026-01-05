import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/materi.dart';

class MateriRemoteDatasource {
  final FirebaseFirestore firestore;
  MateriRemoteDatasource(this.firestore);

  Stream<List<Materi>> getMateriByKelas(String kelasId) {
    return firestore
        .collection('materi')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final d = doc.data();

            // ✅ null-safe + type-safe
            final createdRaw = d['createdAt'];
            DateTime createdAt;

            if (createdRaw is Timestamp) {
              createdAt = createdRaw.toDate();
            } else if (createdRaw is DateTime) {
              createdAt = createdRaw;
            } else {
              createdAt = DateTime.now(); // fallback aman
            }

            return Materi(
              id: doc.id,
              kelasId: (d['kelasId'] ?? '').toString(),
              kelasNama: (d['kelasNama'] ?? '').toString(),
              judul: (d['judul'] ?? '').toString(),
              deskripsi: (d['deskripsi'] ?? '').toString(),
              fileUrl: d['fileUrl']?.toString(),
              fileType: d['fileType']?.toString(),
              createdAt: createdAt,
            );
          }).toList();
        });
  }

  Future<void> addMateri(Materi m) async {
    await firestore.collection('materi').add({
      'kelasId': m.kelasId,
      'kelasNama': m.kelasNama,
      'judul': m.judul,
      'deskripsi': m.deskripsi,
      'fileUrl': m.fileUrl,
      'fileType': m.fileType,
      // ✅ pastikan selalu Timestamp
      'createdAt': Timestamp.fromDate(m.createdAt),
    });
  }

  Future<void> updateMateri(Materi m) async {
    await firestore.collection('materi').doc(m.id).update({
      'judul': m.judul,
      'deskripsi': m.deskripsi,
      'fileUrl': m.fileUrl,
      'fileType': m.fileType,
    });
  }

  Future<void> deleteMateri(String id) async {
    await firestore.collection('materi').doc(id).delete();
  }
}
