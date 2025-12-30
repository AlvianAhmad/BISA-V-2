import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bisa/presentation/pages/auth/login_page.dart';

class AdminDashboardViewModel
    extends
        ChangeNotifier {
  // ignore: unused_field
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminDashboardViewModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth =
           auth ??
           FirebaseAuth.instance,
       _firestore =
           firestore ??
           FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  int mahasiswaCount = 0;
  int dosenCount = 0;

  StreamSubscription<
    QuerySnapshot
  >?
  _userSub;
  bool _initialized = false;

  /// 🔥 REALTIME INIT
  void init() {
    if (_initialized) return;
    _initialized = true;

    isLoading = true;
    notifyListeners();

    _userSub = _firestore
        .collection(
          'users',
        )
        .snapshots()
        .listen(
          (
            snapshot,
          ) {
            int mahasiswa = 0;
            int dosen = 0;

            for (final doc in snapshot.docs) {
              final role = doc['role'];
              if (role ==
                  'mahasiswa')
                mahasiswa++;
              if (role ==
                  'dosen')
                dosen++;
            }

            mahasiswaCount = mahasiswa;
            dosenCount = dosen;

            isLoading = false;
            notifyListeners();
          },
          onError:
              (
                e,
              ) {
                errorMessage = e.toString();
                isLoading = false;
                notifyListeners();
              },
        );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  // ================= UI HELPERS =================

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

  // ================= LOGOUT =================

  Future<
    void
  >
  logoutWithConfirm({
    required BuildContext context,
    required PageRoute Function(
      Widget page,
    )
    routeBuilder,
    required Color primaryColor,
  }) async {
    final confirm = await _showLogoutDialog(
      context,
      primaryColor: primaryColor,
    );

    if (confirm !=
        true)
      return;
    if (!context.mounted) return;

    // TODO: signOut kamu di sini (FirebaseAuth / dsb)
    // await FirebaseAuth.instance.signOut();

    // bersihin stack -> ke login
    Navigator.of(
      context,
    ).pushAndRemoveUntil(
      routeBuilder(
        const LoginPage(),
      ), // sesuaikan LoginPage kamu
      (
        route,
      ) => false,
    );
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
        0.45,
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
                // ===== BLUR BACKGROUND =====
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 4, // blur halus (jangan besar)
                    sigmaY: 4,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.25,
                    ), // gelap tipis
                  ),
                ),

                // ===== DIALOG CARD =====
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.12,
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
                            // icon
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
                              'Anda akan keluar dari akun admin.\nPastikan semua perubahan sudah tersimpan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                color: Color(
                                  0xFF6F7AA6,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 18,
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
                                        color: Colors.white,
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
