import 'package:flutter/material.dart';

import 'app_routes.dart';

// AUTH
import '../presentation/pages/welcome_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/auth_gate_page.dart';

// ROLE PAGES
import '../presentation/pages/admin/admin_page.dart';
import '../presentation/pages/dosen/dosen_page.dart';
import '../presentation/pages/mahasiswa/mahasiswa_page.dart';

class AppRouter {
  AppRouter._();

  static Route<
    dynamic
  >
  onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _page(
          const WelcomePage(),
        );

      case AppRoutes.login:
        return _page(
          const LoginPage(),
        );

      case AppRoutes.register:
        return _page(
          const RegisterPage(),
        );

      case AppRoutes.admin:
        return _page(
          const AdminPage(),
        );

      case AppRoutes.dosen:
        return _page(
          const DosenPage(),
        );

      case AppRoutes.mahasiswa:
        return _page(
          const MahasiswaPage(),
        );

      case AppRoutes.authGate:
        return _page(
          const AuthGatePage(),
        );

      default:
        return _unknownRoute(
          settings.name,
        );
    }
  }

  static MaterialPageRoute _page(
    Widget page,
  ) {
    return MaterialPageRoute(
      builder:
          (
            _,
          ) => page,
    );
  }

  static MaterialPageRoute _unknownRoute(
    String? routeName,
  ) {
    return MaterialPageRoute(
      builder:
          (
            _,
          ) => Scaffold(
            appBar: AppBar(
              title: const Text(
                'Error',
              ),
            ),
            body: Center(
              child: Text(
                'Route tidak ditemukan:\n$routeName',
                textAlign: TextAlign.center,
              ),
            ),
          ),
    );
  }
}
