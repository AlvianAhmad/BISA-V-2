import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthViewModel
    extends
        ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel(
    this.repository,
  );

  bool isLoading = false;
  String? errorMessage;

  // ================= LOGIN =================
  Future<
    String?
  >
  login(
    String email,
    String password,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      return await repository.login(
        email,
        password,
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

  // ================= LOGIN GOOGLE =================
  Future<
    String?
  >
  loginWithGoogle() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      return await repository.loginWithGoogle();
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

  // ================= REGISTER MAHASISWA =================
  Future<
    void
  >
  registerMahasiswa({
    required String nama,
    required String username,
    required String nim,
    required String programStudi,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.registerMahasiswa(
        nama: nama,
        username: username,
        nim: nim,
        programStudi: programStudi,
        email: email,
        password: password,
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

  // ================= RESET PASSWORD =================
  Future<
    void
  >
  resetPassword(
    String email,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.resetPassword(
        email,
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

  // ================= GET ROLE =================
  Future<
    String?
  >
  getRole(
    String uid,
  ) async {
    try {
      return await repository.getRole(
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
}
