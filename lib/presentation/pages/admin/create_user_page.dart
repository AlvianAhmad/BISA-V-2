import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/admin/admin_viewmodel.dart';

class CreateUserPage
    extends
        StatefulWidget {
  const CreateUserPage({
    super.key,
  });

  @override
  State<
    CreateUserPage
  >
  createState() => _CreateUserPageState();
}

class _CreateUserPageState
    extends
        State<
          CreateUserPage
        > {
  String role = 'mahasiswa';

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final nimC = TextEditingController();
  final prodiC = TextEditingController();
  final nidnC = TextEditingController();

  @override
  Widget build(
    BuildContext context,
  ) {
    final vm = context
        .read<
          AdminViewModel
        >();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Akun User',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            // ===== PILIH ROLE =====
            DropdownButtonFormField<
              String
            >(
              value: role,
              decoration: const InputDecoration(
                labelText: 'Pilih Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'mahasiswa',
                  child: Text(
                    'Mahasiswa',
                  ),
                ),
                DropdownMenuItem(
                  value: 'dosen',
                  child: Text(
                    'Dosen',
                  ),
                ),
              ],
              onChanged:
                  (
                    value,
                  ) {
                    setState(
                      () {
                        role = value!;
                      },
                    );
                  },
            ),

            const SizedBox(
              height: 16,
            ),

            _field(
              namaC,
              'Nama',
            ),
            _field(
              emailC,
              'Email',
            ),

            // ===== FIELD KHUSUS MAHASISWA =====
            if (role ==
                'mahasiswa') ...[
              _field(
                nimC,
                'NIM',
              ),
              _field(
                prodiC,
                'Program Studi',
              ),
            ],

            // ===== FIELD KHUSUS DOSEN =====
            if (role ==
                'dosen') ...[
              _field(
                nidnC,
                'NIDN',
              ),
            ],

            const SizedBox(
              height: 30,
            ),

            ElevatedButton(
              onPressed: () async {
                final data = {
                  'nama': namaC.text,
                  'email': emailC.text,
                  'role': role,
                  'createdAt': DateTime.now(),
                };

                if (role ==
                    'mahasiswa') {
                  data.addAll(
                    {
                      'nim': nimC.text,
                      'programStudi': prodiC.text,
                    },
                  );
                } else {
                  data.addAll(
                    {
                      'nidn': nidnC.text,
                    },
                  );
                }

                await vm.createUser(
                  role: role,
                  email: emailC.text,
                  data: data,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Akun berhasil dibuat (password: 123456)',
                    ),
                  ),
                );

                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Simpan Akun',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
