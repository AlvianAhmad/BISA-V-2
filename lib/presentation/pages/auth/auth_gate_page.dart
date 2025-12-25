import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../routes/app_routes.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ===== LOGOUT / BELUM LOGIN =====
        if (!snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          });
          return const SizedBox();
        }

        // ===== LOGIN =====
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // sementara langsung admin
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.admin,
            (route) => false,
          );
        });

        return const SizedBox();
      },
    );
  }
}
