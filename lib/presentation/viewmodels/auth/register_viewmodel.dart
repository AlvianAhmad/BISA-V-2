import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository repository;

  RegisterViewModel(this.repository);

  // ✅ Controllers
  final nameC = TextEditingController();
  final phoneC = TextEditingController(); // kalau masih mau disimpan (opsional)
  final usernameC = TextEditingController();
  final nimC = TextEditingController();
  final programStudiC = TextEditingController();

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

  void toggleAgree(bool value) {
    agree = value;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  bool _isValidEmail(String s) {
    final email = s.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  String _mapRegisterError(String raw) {
    final s = raw.trim();

    final match = RegExp(r'\[firebase_auth\/([^\]]+)\]').firstMatch(s);
    final code = match?.group(1);

    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi bermasalah. Cek internet kamu.';
      default:
        break;
    }

    if (s.startsWith('Exception: ')) return s.replaceFirst('Exception: ', '');
    if (s.contains('[firebase_auth/')) return 'Registrasi gagal. Coba lagi.';
    return s.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : s;
  }

  Future<bool> register() async {
    errorMessage = null;

    final nama = nameC.text.trim();
    final phone = phoneC.text.trim(); // opsional
    final username = usernameC.text.trim();
    final nim = nimC.text.trim();
    final prodi = programStudiC.text.trim();
    final email = emailC.text.trim();
    final pass = passwordC.text;
    final confirm = confirmPasswordC.text;

    // ✅ Validasi
    if (nama.isEmpty) return _error('Nama tidak boleh kosong.');
    if (phone.isEmpty) return _error('Nomor telepon tidak boleh kosong.');
    if (username.isEmpty) return _error('Username tidak boleh kosong.');
    if (nim.isEmpty) return _error('NIM tidak boleh kosong.');
    if (prodi.isEmpty) return _error('Program studi tidak boleh kosong.');
    if (!_isValidEmail(email)) return _error('Email tidak valid.');
    if (pass.trim().length < 6) return _error('Password minimal 6 karakter.');
    if (pass != confirm) return _error('Konfirmasi password tidak sama.');
    if (!agree) return _error('Harus menyetujui syarat & ketentuan.');

    isLoading = true;
    notifyListeners();

    try {
      await repository.registerMahasiswa(
        nama: nama,
        username: username,
        nim: nim,
        programStudi: prodi,
        email: email,
        password: pass,
      );

      return true;
    } catch (e) {
      errorMessage = _mapRegisterError(e.toString());
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _error(String msg) {
    errorMessage = msg;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    usernameC.dispose();
    nimC.dispose();
    programStudiC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }
}
