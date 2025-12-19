import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class RegisterViewModel
    extends
        ChangeNotifier {
  final AuthRepository repository;

  RegisterViewModel(
    this.repository,
  );

  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  bool agree = false;
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? errorMessage;

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  void toggleAgree(
    bool value,
  ) {
    agree = value;
    notifyListeners();
  }

  Future<
    bool
  >
  register() async {
    errorMessage = null;

    if (nameC.text.isEmpty) {
      return _error(
        "Nama tidak boleh kosong",
      );
    }
    if (phoneC.text.isEmpty) {
      return _error(
        "Nomor telepon tidak boleh kosong",
      );
    }
    if (!emailC.text.contains(
      '@',
    )) {
      return _error(
        "Email tidak valid",
      );
    }
    if (passwordC.text.length <
        6) {
      return _error(
        "Password minimal 6 karakter",
      );
    }
    if (passwordC.text !=
        confirmPasswordC.text) {
      return _error(
        "Password tidak sama",
      );
    }
    if (!agree) {
      return _error(
        "Harus menyetujui syarat",
      );
    }

    isLoading = true;
    notifyListeners();

    try {
      await repository.registerMahasiswa(
        nama: nameC.text,
        username: phoneC.text,
        nim: '-',
        programStudi: '-',
        email: emailC.text,
        password: passwordC.text,
      );
      return true;
    } catch (
      e
    ) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _error(
    String msg,
  ) {
    errorMessage = msg;
    notifyListeners();
    return false;
  }
}
