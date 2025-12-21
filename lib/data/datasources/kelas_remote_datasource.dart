import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/kelas.dart';

class KelasRemoteDataSource {
  final FirebaseFirestore firestore;

  KelasRemoteDataSource(this.firestore);

  Stream<List<Kelas>> getKelas() {
    return firestore.collection('kelas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Kelas(
          id: doc.id,
          nama: d['nama'],
          jurusan: d['jurusan'],
          semester: d['semester'],
        );
      }).toList();
    });
  }

  Future<void> addKelas(Kelas kelas) async {
    await firestore.collection('kelas').add({
      'nama': kelas.nama,
      'jurusan': kelas.jurusan,
      'semester': kelas.semester,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateKelas(Kelas kelas) async {
    await firestore.collection('kelas').doc(kelas.id).update({
      'nama': kelas.nama,
      'jurusan': kelas.jurusan,
      'semester': kelas.semester,
    });
  }

  Future<void> deleteKelas(String id) async {
    await firestore.collection('kelas').doc(id).delete();
  }
}
