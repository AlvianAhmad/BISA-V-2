import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final _db = FirebaseFirestore.instance;

  // ===== KELAS =====
  Future<List<String>> getKelas() async {
    final snap = await _db.collection('kelas').get();
    return snap.docs.map((d) => d['nama'].toString()).toList();
  }

  // ===== JADWAL =====
  Future<List<Map<String, dynamic>>> getJadwal() async {
    final snap = await _db.collection('jadwal').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ===== TUGAS =====
  Future<List<Map<String, dynamic>>> getTugas() async {
    final snap = await _db.collection('tugas').get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ===== MATERI =====
  Future<List<Map<String, dynamic>>> getMateri() async {
    final snap = await _db.collection('materi').get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
