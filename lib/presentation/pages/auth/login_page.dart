import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../viewmodels/auth/login_viewmodel.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _redirect(BuildContext context, String role) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.admin);
    } else if (role == 'dosen') {
      Navigator.pushReplacementNamed(context, AppRoutes.dosen);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.mahasiswa);
    }
  }

  // ✅ validasi email sederhana
  bool _isEmail(String input) {
    final s = input.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
  }

  Widget _input({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF204D9C),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF89A7C2), Color(0xFF1E3C72)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.welcome,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        CircleAvatar(
                          radius: 65,
                          backgroundColor: const Color(0xFF002F6C),
                          child: Image.asset(
                            'assets/images/bisaa.png',
                            height: 60,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          "Masuk",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 25),

                        _input(
                          hint: "Masukkan Email atau Username",
                          controller: vm.inputC,
                        ),

                        _input(
                          hint: "Masukkan Password",
                          controller: vm.passwordC,
                          obscure: !vm.showPassword,
                          suffix: IconButton(
                            icon: Icon(
                              vm.showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: vm.togglePassword,
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (vm.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              vm.errorMessage!,
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                                    final uid = await vm.login();
                                    if (uid != null) {
                                      final role = await vm.getRole(uid);
                                      if (role != null && context.mounted) {
                                        _redirect(context, role);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E2E72),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white)),
                            Text(
                              "  atau  ",
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            const Expanded(child: Divider(color: Colors.white)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        OutlinedButton.icon(
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                                  final uid = await vm.loginWithGoogle();
                                  if (uid != null) {
                                    final role = await vm.getRole(uid);
                                    if (role != null && context.mounted) {
                                      _redirect(context, role);
                                    }
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            height: 20,
                          ),
                          label: Text(
                            "Masuk dengan Google",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ✅ RESET PASSWORD (SUDAH PASS email)
                        TextButton(
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                                  final input = vm.inputC.text.trim();

                                  // wajib email (reset password Firebase cuma bisa email)
                                  if (!_isEmail(input)) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Untuk reset password, masukkan EMAIL yang valid (bukan username).',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await vm.resetPassword(email: input);

                                  if (!context.mounted) return;

                                  if (vm.errorMessage == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Link reset password dikirim ke email (cek Spam/Promosi).',
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(vm.errorMessage!)),
                                    );
                                  }
                                },
                          child: Text(
                            "Lupa Password?",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Anda belum punya akun? ",
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: Text(
                                "Daftar",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (vm.isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
