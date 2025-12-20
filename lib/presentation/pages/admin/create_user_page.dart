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

  final _formKey =
      GlobalKey<
        FormState
      >();
  bool _submitting = false;

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final nimC = TextEditingController();
  final prodiC = TextEditingController();
  final nidnC = TextEditingController();

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    nimC.dispose();
    prodiC.dispose();
    nidnC.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _submit(
    AdminViewModel vm,
  ) async {
    final valid =
        _formKey.currentState?.validate() ??
        false;
    if (!valid) return;

    setState(
      () => _submitting = true,
    );

    final data =
        <
          String,
          dynamic
        >{
          'nama': namaC.text.trim(),
          'email': emailC.text.trim(),
          'role': role,
          'createdAt': DateTime.now(),
        };

    if (role ==
        'mahasiswa') {
      data.addAll(
        {
          'nim': nimC.text.trim(),
          'programStudi': prodiC.text.trim(),
        },
      );
    } else {
      data.addAll(
        {
          'nidn': nidnC.text.trim(),
        },
      );
    }

    try {
      await vm.createUser(
        role: role,
        email: emailC.text.trim(),
        data: data,
      );

      if (!mounted) return;

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
    } catch (
      e
    ) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat akun: $e',
          ),
        ),
      );
    } finally {
      if (mounted)
        setState(
          () => _submitting = false,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F7FF,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Buat Akun User',
          style: TextStyle(
            color: Color(
              0xFF1A2552,
            ),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(
            0xFF1A2552,
          ),
        ),
      ),
      body:
          Consumer<
            AdminViewModel
          >(
            builder:
                (
                  context,
                  vm,
                  _,
                ) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          24,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // HEADER
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                  16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(
                                        0xFF0E2E72,
                                      ),
                                      Color(
                                        0xFF1E54B7,
                                      ),
                                      Color(
                                        0xFF3A7BD5,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        0.10,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(
                                        0,
                                        10,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(
                                          0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tambah Akun Baru',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            'Pilih role, isi data, lalu simpan akun.',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              // FORM CARD
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                  16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    18,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        0.06,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(
                                        0,
                                        8,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Informasi Akun',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: const Color(
                                          0xFF1A2552,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),

                                    DropdownButtonFormField<
                                      String
                                    >(
                                      value: role,
                                      decoration: _inputDecoration(
                                        label: 'Role',
                                        hint: 'Pilih role user',
                                        icon: Icons.badge_rounded,
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
                                      onChanged: _submitting
                                          ? null
                                          : (
                                              value,
                                            ) {
                                              if (value ==
                                                  null)
                                                return;
                                              setState(
                                                () {
                                                  role = value;
                                                  if (role ==
                                                      'mahasiswa') {
                                                    nidnC.clear();
                                                  } else {
                                                    nimC.clear();
                                                    prodiC.clear();
                                                  }
                                                },
                                              );
                                            },
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    TextFormField(
                                      controller: namaC,
                                      textInputAction: TextInputAction.next,
                                      enabled: !_submitting,
                                      decoration: _inputDecoration(
                                        label: 'Nama',
                                        hint: 'Contoh: Budi Santoso',
                                        icon: Icons.person_rounded,
                                      ),
                                      validator:
                                          (
                                            v,
                                          ) {
                                            final value =
                                                v?.trim() ??
                                                '';
                                            if (value.isEmpty) return 'Nama wajib diisi';
                                            if (value.length <
                                                3)
                                              return 'Nama minimal 3 karakter';
                                            return null;
                                          },
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    TextFormField(
                                      controller: emailC,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      enabled: !_submitting,
                                      decoration: _inputDecoration(
                                        label: 'Email',
                                        hint: 'contoh@email.com',
                                        icon: Icons.email_rounded,
                                      ),
                                      validator:
                                          (
                                            v,
                                          ) {
                                            final value =
                                                v?.trim() ??
                                                '';
                                            if (value.isEmpty) return 'Email wajib diisi';
                                            if (!value.contains(
                                              '@',
                                            ))
                                              return 'Format email tidak valid';
                                            return null;
                                          },
                                    ),

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    if (role ==
                                        'mahasiswa') ...[
                                      TextFormField(
                                        controller: nimC,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        enabled: !_submitting,
                                        decoration: _inputDecoration(
                                          label: 'NIM',
                                          hint: 'Masukkan NIM',
                                          icon: Icons.numbers_rounded,
                                        ),
                                        validator:
                                            (
                                              v,
                                            ) {
                                              if (role !=
                                                  'mahasiswa')
                                                return null;
                                              final value =
                                                  v?.trim() ??
                                                  '';
                                              if (value.isEmpty) return 'NIM wajib diisi';
                                              if (value.length <
                                                  5)
                                                return 'NIM terlalu pendek';
                                              return null;
                                            },
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      TextFormField(
                                        controller: prodiC,
                                        textInputAction: TextInputAction.done,
                                        enabled: !_submitting,
                                        decoration: _inputDecoration(
                                          label: 'Program Studi',
                                          hint: 'Contoh: Informatika',
                                          icon: Icons.school_rounded,
                                        ),
                                        validator:
                                            (
                                              v,
                                            ) {
                                              if (role !=
                                                  'mahasiswa')
                                                return null;
                                              final value =
                                                  v?.trim() ??
                                                  '';
                                              if (value.isEmpty) return 'Program Studi wajib diisi';
                                              return null;
                                            },
                                      ),
                                    ],

                                    if (role ==
                                        'dosen') ...[
                                      TextFormField(
                                        controller: nidnC,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        enabled: !_submitting,
                                        decoration: _inputDecoration(
                                          label: 'NIDN',
                                          hint: 'Masukkan NIDN',
                                          icon: Icons.badge_rounded,
                                        ),
                                        validator:
                                            (
                                              v,
                                            ) {
                                              if (role !=
                                                  'dosen')
                                                return null;
                                              final value =
                                                  v?.trim() ??
                                                  '';
                                              if (value.isEmpty) return 'NIDN wajib diisi';
                                              if (value.length <
                                                  5)
                                                return 'NIDN terlalu pendek';
                                              return null;
                                            },
                                      ),
                                    ],

                                    const SizedBox(
                                      height: 16,
                                    ),

                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(
                                              0xFF0E2E72,
                                            ).withOpacity(
                                              0.06,
                                            ),
                                        borderRadius: BorderRadius.circular(
                                          14,
                                        ),
                                        border: Border.all(
                                          color:
                                              const Color(
                                                0xFF0E2E72,
                                              ).withOpacity(
                                                0.10,
                                              ),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: Color(
                                              0xFF0E2E72,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Password default: 123456\nUser bisa reset password setelah login.',
                                              style: TextStyle(
                                                color: Color(
                                                  0xFF1A2552,
                                                ),
                                                fontWeight: FontWeight.w600,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 16,
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.save_rounded,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Simpan Akun',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0E2E72,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        onPressed: _submitting
                                            ? null
                                            : () => _submit(
                                                vm,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // LOADING OVERLAY
                      if (_submitting)
                        Container(
                          color: Colors.black.withOpacity(
                            0.35,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  );
                },
          ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
      ),
      filled: true,
      fillColor: const Color(
        0xFFF6F8FF,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          14,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xFF0E2E72,
          ),
          width: 1.4,
        ),
      ),
    );
  }
}
