import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
//import 'login_page.dart';

class DosenPage
    extends
        StatelessWidget {
  const DosenPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final authVM = context
        .read<
          AuthViewModel
        >();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dosen',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await authVM.repository.resetPassword; // dummy biar ga auto lint
              await authVM.repository.resetPassword; // abaikan (akan kita benerin)
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.logout,
          ),
          label: const Text(
            'Logout',
          ),
          onPressed: () async {
            await authVM.repository.resetPassword; // dummy biar ga auto lint
          },
        ),
      ),
    );
  }
}
