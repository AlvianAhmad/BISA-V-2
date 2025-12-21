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
            return Materi(
              id: doc.id,
              kelasId: d['kelasId'],
              kelasNama: d['kelasNama'],
              judul: d['judul'],
              deskripsi: d['deskripsi'],
              fileUrl: d['fileUrl'],
              fileType: d['fileType'],
              createdAt: (d['createdAt'] as Timestamp).toDate(),
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
