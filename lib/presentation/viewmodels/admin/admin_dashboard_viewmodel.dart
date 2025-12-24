// lib/presentation/pages/admin/admin_dashboard_viewmodel.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bisa/presentation/pages/auth/login_page.dart';

class AdminDashboardViewModel
    extends
        ChangeNotifier {
  final FirebaseAuth _auth;

  AdminDashboardViewModel({
    FirebaseAuth? auth,
  }) : _auth =
           auth ??
           FirebaseAuth.instance;

  bool isLoading = false;
  String? errorMessage;

  int mahasiswaCount = 0;
  int dosenCount = 0;

  bool _initialized = false;

  /// Panggil ini saat AdminPage dibuka.
  Future<
    void
  >
  init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // TODO: ganti dengan repository/usecase untuk ambil data real
      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );
      mahasiswaCount = 0;
      dosenCount = 0;
    } catch (
      e
    ) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void snack(
    BuildContext context,
    String msg,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

  void onTapNotifications(
    BuildContext context,
  ) {
    snack(
      context,
      'Notifikasi belum tersedia',
    );
  }

  void onTapSettings(
    BuildContext context,
  ) {
    snack(
      context,
      'Pengaturan belum tersedia',
    );
  }

  void onTapNotImplemented(
    BuildContext context,
    String featureName,
  ) {
    snack(
      context,
      '$featureName belum dihubungkan',
    );
  }

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
    final confirm =
        await showDialog<
          bool
        >(
          context: context,
          barrierDismissible: false,
          builder:
              (
                ctx,
              ) {
                return AlertDialog(
                  title: const Text(
                    'Konfirmasi Logout',
                  ),
                  content: const Text(
                    'Yakin logout?',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        false,
                      ),
                      child: const Text(
                        'Batal',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(
                        ctx,
                        true,
                      ),
                      icon: const Icon(
                        Icons.logout_rounded,
                      ),
                      label: const Text(
                        'Logout',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor ??
                            const Color(
                              0xFF0E2E72,
                            ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
        );

    if (confirm !=
        true) {
      return;
    }

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
  }
}
