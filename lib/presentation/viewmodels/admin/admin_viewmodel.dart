import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/auth_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminViewModel(this.repository) {
    _listenUserCount();
  }

  int mahasiswaCount = 0;
  int dosenCount = 0;

  StreamSubscription? _userSub;

  // ================= LISTEN USER COUNT =================
  void _listenUserCount() {
    _userSub = _firestore.collection('users').snapshots().listen((snapshot) {
      int mahasiswa = 0;
      int dosen = 0;

      for (final doc in snapshot.docs) {
        final role = doc.data()['role'];
        if (role == 'mahasiswa') mahasiswa++;
        if (role == 'dosen') dosen++;
      }

      mahasiswaCount = mahasiswa;
      dosenCount = dosen;
      notifyListeners();
    });
  }

  // ================= ADMIN CREATE USER =================
  Future<void> createUser({
    required String email,
    required String role,
    required Map<String, dynamic> data,
  }) async {
    await repository.createUserByAdmin(
      email: email,
      password: '123456',
      role: role,
      data: data,
    );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
