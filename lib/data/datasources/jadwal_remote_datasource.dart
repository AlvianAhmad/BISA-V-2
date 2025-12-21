import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/jadwal.dart';

class JadwalRemoteDataSource {
  final FirebaseFirestore firestore;

  JadwalRemoteDataSource(this.firestore);

  Stream<List<Jadwal>> getJadwal() {
    return firestore.collection('jadwal').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Jadwal(
          id: doc.id,
          mataKuliah: d['mataKuliah'],
          dosen: d['dosen'],
          kelas: d['kelas'],
          hari: d['hari'],
          jam: d['jam'],
        );
      }).toList();
    });
  }

  Future<void> addJadwal(Jadwal jadwal) async {
    await firestore.collection('jadwal').add({
      'mataKuliah': jadwal.mataKuliah,
      'dosen': jadwal.dosen,
      'kelas': jadwal.kelas,
      'hari': jadwal.hari,
      'jam': jadwal.jam,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateJadwal(Jadwal jadwal) async {
    await firestore.collection('jadwal').doc(jadwal.id).update({
      'mataKuliah': jadwal.mataKuliah,
      'dosen': jadwal.dosen,
      'kelas': jadwal.kelas,
      'hari': jadwal.hari,
      'jam': jadwal.jam,
    });
  }

  Future<void> deleteJadwal(String id) async {
    await firestore.collection('jadwal').doc(id).delete();
  }
}
