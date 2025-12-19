import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginViewModel
    extends
        ChangeNotifier {
  final AuthRepository _repo;
  LoginViewModel(
    this._repo,
  );

  // Controllers pindah ke VM
  final inputC = TextEditingController();
  final passwordC = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  String? errorMessage;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<
    String?
  >
  login() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final input = inputC.text.trim();
      final pass = passwordC.text.trim();

      if (input.isEmpty)
        throw Exception(
          'Email/Username tidak boleh kosong',
        );
      if (pass.isEmpty)
        throw Exception(
          'Password tidak boleh kosong',
        );

      // NOTE: repo kamu saat ini login(email,password).
      // Kalau input username, kamu perlu mapping username->email dulu.
      return await _repo.login(
        input,
        pass,
      );
    } catch (
      e
    ) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<
    String?
  >
  loginWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      return await _repo.loginWithGoogle();
    } catch (
      e
    ) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<
    void
  >
  resetPassword() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final input = inputC.text.trim();
      if (!input.contains(
        '@',
      )) {
        throw Exception(
          'Masukkan EMAIL untuk reset password',
        );
      }

      await _repo.resetPassword(
        input,
      );
    } catch (
      e
    ) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<
    String?
  >
  getRole(
    String uid,
  ) async {
    try {
      return await _repo.getRole(
        uid,
      );
    } catch (
      e
    ) {
      errorMessage = e.toString();
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
