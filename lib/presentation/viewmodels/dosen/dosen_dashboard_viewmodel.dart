import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';

class DosenDashboardViewModel
    extends
        ChangeNotifier {
  final FirebaseAuth _auth;

  DosenDashboardViewModel({
    FirebaseAuth? auth,
  }) : _auth =
           auth ??
           FirebaseAuth.instance;

  bool isLoading = false;
  bool _initialized = false;

  // ====== RINGKASAN (biar dashboard dosen ga error) ======
  int _kelasCount = 0;
  int _tugasCount = 0;
  int _absensiCount = 0;

  int get kelasCount => _kelasCount;
  int get tugasCount => _tugasCount;
  int get absensiCount => _absensiCount;

  // ================= INIT =================
  Future<
    void
  >
  init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      isLoading = true;
      notifyListeners();

      // TODO: nanti ambil data beneran dari Firestore
      // sementara dummy dulu biar UI dashboard aman
      await Future.delayed(
        const Duration(
          milliseconds: 200,
        ),
      );
      _kelasCount = 0;
      _tugasCount = 0;
      _absensiCount = 0;
    } catch (
      e
    ) {
      debugPrint(
        'Dosen init error: $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= SNACK (modern) =================
  void snack(
    BuildContext context,
    String msg, {
    bool success = true,
  }) {
    final bg = success
        ? const Color(
            0xFF0E2E72,
          )
        : const Color(
            0xFFE53935,
          );

    ScaffoldMessenger.of(
        context,
      )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(
            seconds: 3,
          ),
        ),
      );
  }

  // ================= LOGOUT (popup premium + blur) =================
  Future<
    void
  >
  logoutWithConfirm({
    required BuildContext context,
    required PageRoute Function(
      Widget page,
    )
    routeBuilder,
    Color? primaryColor,
  }) async {
    final confirm = await _showLogoutDialog(
      context,
      primaryColor:
          primaryColor ??
          const Color(
            0xFF0E2E72,
          ),
    );

    if (confirm !=
        true)
      return;

    try {
      await _auth.signOut();
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        routeBuilder(
          const LoginPage(),
        ),
        (
          _,
        ) => false,
      );
    } catch (
      e
    ) {
      if (!context.mounted) return;
      snack(
        context,
        'Logout gagal: $e',
        success: false,
      );
    }
  }

  Future<
    bool?
  >
  _showLogoutDialog(
    BuildContext context, {
    required Color primaryColor,
  }) {
    return showGeneralDialog<
      bool
    >(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'logout',
      barrierColor: Colors.black.withOpacity(
        0.35,
      ),
      transitionDuration: const Duration(
        milliseconds: 220,
      ),
      pageBuilder:
          (
            ctx,
            __,
            ___,
          ) {
            return Stack(
              children: [
                // ===== background blur =====
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 4,
                    sigmaY: 4,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.15,
                    ),
                  ),
                ),

                // ===== dialog =====
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          18,
                          18,
                          14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                          border: Border.all(
                            color: Colors.black.withOpacity(
                              0.06,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.10,
                              ),
                              blurRadius: 24,
                              offset: const Offset(
                                0,
                                14,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(
                                  0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                                border: Border.all(
                                  color: Colors.red.withOpacity(
                                    0.12,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Text(
                              'Konfirmasi Logout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: Color(
                                  0xFF1A2552,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              'Anda akan keluar dari akun dosen.\nPastikan semua perubahan sudah tersimpan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color: Color(
                                  0xFF6F7AA6,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(
                                          ctx,
                                        ).pop(
                                          false,
                                        ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(
                                        0xFF1A2552,
                                      ),
                                      side: BorderSide(
                                        color: Colors.black.withOpacity(
                                          0.10,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(
                                          ctx,
                                        ).pop(
                                          true,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
      transitionBuilder:
          (
            ctx,
            anim,
            __,
            child,
          ) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale:
                    Tween<
                          double
                        >(
                          begin: 0.96,
                          end: 1.0,
                        )
                        .animate(
                          curved,
                        ),
                child: child,
              ),
            );
          },
    );
  }
}
