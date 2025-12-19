import 'package:flutter/material.dart';
import 'create_user_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Buat Akun Mahasiswa / Dosen'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateUserPage()),
            );
          },
        ),
      ),
    );
  }
}
