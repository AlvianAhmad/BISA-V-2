import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TugasViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil tugas berdasarkan kelas
  Stream<QuerySnapshot> getTugasByKelas(String kelasId) {
    return _firestore
        .collection('tugas')
        .where('kelasId', isEqualTo: kelasId)
        .snapshots();
  }
}
