import 'package:flutter/material.dart';

class AdminDashboardViewModel
    extends
        ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  int mahasiswaCount = 0;
  int dosenCount = 0;

  /// Panggil ini saat AdminPage dibuka.
  Future<
    void
  >
  init() async {
    // biar init cuma sekali (optional)
    if (isLoading) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // TODO: nanti ganti dengan UseCase / Repository (Clean Arch)
      // sementara dummy dulu
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

  void onTapNotifications(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Notifikasi belum tersedia',
        ),
      ),
    );
  }

  void onTapSettings(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Pengaturan belum tersedia',
        ),
      ),
    );
  }

  void onTapNotImplemented(
    BuildContext context,
    String featureName,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName belum dihubungkan',
        ),
      ),
    );
  }
}
