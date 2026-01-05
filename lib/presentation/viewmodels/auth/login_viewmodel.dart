import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  LoginViewModel(this._repo);

  final inputC = TextEditingController();
  final passwordC = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  String? errorMessage;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseAuthMessage(String raw) {
    final s = raw.trim();

    // Ambil code dari format: [firebase_auth/invalid-email] ...
    final match = RegExp(r'\[firebase_auth\/([^\]]+)\]').firstMatch(s);
    final code = match?.group(1);

    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Cek email/username kamu.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'invalid-credential':
        return 'Email/username atau password salah.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Koneksi bermasalah. Cek internet kamu.';
      case 'operation-not-allowed':
        return 'Metode login belum diaktifkan di Firebase.';
      default:
        break;
    }

    // fallback kalau ada "Exception: ..."
    if (s.startsWith('Exception: ')) return s.replaceFirst('Exception: ', '');

    // fallback kalau masih ada format firebase_auth tapi code tak dikenal
    if (s.contains('[firebase_auth/')) return 'Login gagal. Coba lagi.';

    return s.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : s;
  }

  Future<String?> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final input = inputC.text.trim();
      final pass = passwordC.text.trim();

      if (input.isEmpty) throw Exception('Email/Username wajib diisi.');
      if (pass.isEmpty) throw Exception('Password wajib diisi.');

      final uid = await _repo.login(input, pass);
      return uid;
    } catch (e) {
      errorMessage = _mapFirebaseAuthMessage(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uid = await _repo.loginWithGoogle();
      return uid;
    } catch (e) {
      errorMessage = _mapFirebaseAuthMessage(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final input = inputC.text.trim();
      if (input.isEmpty)
        throw Exception('Masukkan email untuk reset password.');
      if (!input.contains('@')) throw Exception('Masukkan email yang valid.');

      await _repo.resetPassword(input);
    } catch (e) {
      errorMessage = _mapFirebaseAuthMessage(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getRole(String uid) async {
    try {
      return await _repo.getRole(uid);
    } catch (e) {
      errorMessage = _mapFirebaseAuthMessage(e.toString());
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    inputC.dispose();
    passwordC.dispose();
    super.dispose();
  }
}
