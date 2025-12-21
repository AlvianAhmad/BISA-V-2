import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tugas.dart';

class TugasRemoteDataSource {
  final FirebaseFirestore firestore;

  TugasRemoteDataSource(this.firestore);

  Stream<List<Tugas>> getTugas() {
    return firestore.collection('tugas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Tugas(
          id: doc.id,
          judul: d['judul'],
          deskripsi: d['deskripsi'],
          kelas: d['kelas'],
          deadline: (d['deadline'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  Future<void> addTugas(Tugas tugas) async {
    await firestore.collection('tugas').add({
      'judul': tugas.judul,
      'deskripsi': tugas.deskripsi,
      'kelas': tugas.kelas,
      'deadline': Timestamp.fromDate(tugas.deadline),
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateTugas(Tugas tugas) async {
    await firestore.collection('tugas').doc(tugas.id).update({
      'judul': tugas.judul,
      'deskripsi': tugas.deskripsi,
      'kelas': tugas.kelas,
      'deadline': Timestamp.fromDate(tugas.deadline),
    });
  }

  Future<void> deleteTugas(String id) async {
    await firestore.collection('tugas').doc(id).delete();
  }
}
