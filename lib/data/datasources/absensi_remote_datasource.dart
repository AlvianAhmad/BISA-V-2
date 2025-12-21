import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/absensi.dart';

class AbsensiRemoteDatasource {
  final FirebaseFirestore firestore;

  AbsensiRemoteDatasource(this.firestore);

  Stream<List<Absensi>> getAbsensi() {
    return firestore.collection('absensi').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Absensi(
          id: doc.id,
          judul: data['judul'],
          kelas: data['kelas'],
          tanggal: (data['tanggal'] as Timestamp).toDate(),
          jamMulai: data['jamMulai'],
          jamSelesai: data['jamSelesai'],
          aktif: data['aktif'],
        );
      }).toList();
    });
  }

  Future<void> addAbsensi(Absensi a) async {
    await firestore.collection('absensi').add({
      'judul': a.judul,
      'kelas': a.kelas,
      'tanggal': Timestamp.fromDate(a.tanggal),
      'jamMulai': a.jamMulai,
      'jamSelesai': a.jamSelesai,
      'aktif': a.aktif,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAbsensi(Absensi a) async {
    await firestore.collection('absensi').doc(a.id).update({
      'judul': a.judul,
      'kelas': a.kelas,
      'tanggal': Timestamp.fromDate(a.tanggal),
      'jamMulai': a.jamMulai,
      'jamSelesai': a.jamSelesai,
      'aktif': a.aktif,
    });
  }

  Future<void> deleteAbsensi(String id) async {
    await firestore.collection('absensi').doc(id).delete();
  }
}
