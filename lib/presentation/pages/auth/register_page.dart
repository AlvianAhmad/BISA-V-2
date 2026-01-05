import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../viewmodels/auth/register_viewmodel.dart';
import '../../../routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Widget _input(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
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
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF89A7C2), Color(0xFF1E3C72)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
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
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF002F6C),
                          child: Image.asset(
                            'assets/images/bisaa.png',
                            height: 60,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          "Daftar",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ✅ yang sudah ada
                        _input("Nama Lengkap", vm.nameC),
                        _input(
                          "Nomor Telepon",
                          vm.phoneC,
                          keyboardType: TextInputType.phone,
                        ),

                        // ✅ tambahan dari UserEntity
                        _input("Username", vm.usernameC),
                        _input(
                          "NIM",
                          vm.nimC,
                          keyboardType: TextInputType.number,
                        ),
                        _input("Program Studi", vm.programStudiC),

                        _input(
                          "Email",
                          vm.emailC,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        _input(
                          "Password",
                          vm.passwordC,
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
                        _input(
                          "Konfirmasi Password",
                          vm.confirmPasswordC,
                          obscure: !vm.showConfirmPassword,
                          suffix: IconButton(
                            icon: Icon(
                              vm.showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: vm.toggleConfirmPassword,
                          ),
                        ),

                        Row(
                          children: [
                            Checkbox(
                              value: vm.agree,
                              onChanged: (v) => vm.toggleAgree(v ?? false),
                              side: const BorderSide(color: Colors.white),
                            ),
                            const Expanded(
                              child: Text(
                                "Saya setuju syarat & ketentuan",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        if (vm.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              vm.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                                    final success = await vm.register();
                                    if (success && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.login,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E2E72),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Daftar",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (vm.isLoading)
            Container(
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
