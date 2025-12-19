import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';

class WelcomePage
    extends
        StatelessWidget {
  const WelcomePage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF003182,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (
                context,
                constraints,
              ) {
                final h = constraints.maxHeight;

                return Column(
                  children: [
                    SizedBox(
                      height:
                          h *
                          0.04,
                    ), // responsif
                    // ✅ Logo responsif (tidak overflow)
                    SizedBox(
                      height:
                          h *
                          0.30, // 30% tinggi layar
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.asset(
                          'assets/images/bisaa.png',
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                          h *
                          0.02,
                    ),

                    // ✅ Bagian bawah
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                              40,
                            ),
                            topRight: Radius.circular(
                              40,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Learning Management System\nOur Universitas Pakuan",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              "LMS | UNPAK",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            _,
                                          ) => const RegisterPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  backgroundColor: const Color(
                                    0xFF002F6C,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                            _,
                                          ) => const LoginPage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color(
                                      0xFF002F6C,
                                    ),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(
                                      0xFF002F6C,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}
