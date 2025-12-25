import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';

class DosenDashboardViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  DosenDashboardViewModel({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  bool isLoading = false;
  bool _initialized = false;

  // ================= INIT =================
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      isLoading = true;
      notifyListeners();

      // nanti bisa ambil data dosen (kelas, jadwal, dll)
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Dosen init error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= SNACK =================
  void snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
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
