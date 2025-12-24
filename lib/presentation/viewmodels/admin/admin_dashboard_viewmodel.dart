import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bisa/presentation/pages/auth/login_page.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminDashboardViewModel({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  int mahasiswaCount = 0;
  int dosenCount = 0;

  StreamSubscription<QuerySnapshot>? _userSub;
  bool _initialized = false;

  /// 🔥 REALTIME INIT
  void init() {
    if (_initialized) return;
    _initialized = true;

    isLoading = true;
    notifyListeners();

    _userSub = _firestore
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            int mahasiswa = 0;
            int dosen = 0;

            for (final doc in snapshot.docs) {
              final role = doc['role'];
              if (role == 'mahasiswa') mahasiswa++;
              if (role == 'dosen') dosen++;
            }

            mahasiswaCount = mahasiswa;
            dosenCount = dosen;

            isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            errorMessage = e.toString();
            isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  // ================= UI HELPERS =================

  void snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void onTapNotifications(BuildContext context) {
    snack(context, 'Notifikasi belum tersedia');
  }

  void onTapSettings(BuildContext context) {
    snack(context, 'Pengaturan belum tersedia');
  }

  void onTapNotImplemented(BuildContext context, String featureName) {
    snack(context, '$featureName belum dihubungkan');
  }

  // ================= LOGOUT =================

  Future<void> logoutWithConfirm({
    required BuildContext context,
    required PageRoute Function(Widget page) routeBuilder,
    Color? primaryColor,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Yakin logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor ?? const Color(0xFF0E2E72),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _auth.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      routeBuilder(const LoginPage()),
      (_) => false,
    );
  }
}
