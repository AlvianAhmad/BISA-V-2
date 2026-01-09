import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ GANTI IMPORT INI SESUAI LOKASI LOGINPAGE KAMU
import '../../auth/login_page.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  static const Color _primary = Color(0xFF0E2E72);
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Akun',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: user == null
          ? _StateInfo(
              icon: Icons.lock_outline_rounded,
              title: 'Belum login',
              subtitle: 'Silakan login untuk melihat akun.',
              actionLabel: 'Ke Login',
              onAction: () => _goLogin(context),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return const _StateInfo(
                    icon: Icons.error_outline_rounded,
                    title: 'Gagal memuat akun',
                    subtitle: 'Coba cek koneksi / Firestore rules.',
                  );
                }

                final data = snap.data?.data() ?? {};

                final nama = (data['nama'] ?? user.displayName ?? '-')
                    .toString();
                final email = (data['email'] ?? user.email ?? '-').toString();
                final username = (data['username'] ?? '-').toString();
                final role = (data['role'] ?? 'mahasiswa').toString();
                final nim = (data['nim'] ?? '-').toString();
                final programStudi = (data['programStudi'] ?? '-').toString();
                final kelasId = (data['kelasId'] ?? '-').toString();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _ProfileCard(nama: nama, email: email, role: role),
                    const SizedBox(height: 12),

                    _InfoTile(label: 'Username', value: username),
                    _InfoTile(label: 'NIM', value: nim),
                    _InfoTile(label: 'Program Studi', value: programStudi),
                    _InfoTile(label: 'Email', value: email),

                    const SizedBox(height: 14),

                    // ✅ GANTI PASSWORD
                    OutlinedButton.icon(
                      onPressed: () => _openChangePasswordSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(color: _primary.withOpacity(0.25)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.lock_reset_rounded),
                      label: const Text(
                        'Ganti Password',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ LOGOUT
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ok = await _confirmLogout(context);
                        if (ok == true) {
                          await FirebaseAuth.instance.signOut();
                          if (!context.mounted) return;
                          _goLogin(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // UID
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _primary.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: _primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'UID: ${user.uid}',
                              style: const TextStyle(
                                color: _textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // ✅ TANPA ROUTE NAME
  static void _goLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (r) => false,
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ✅ FIX: Change password sheet pakai StatefulWidget terpisah (AMAN)
  void _openChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  static String _mapAuthError(String raw) {
    final s = raw.trim();
    final match = RegExp(r'\[firebase_auth\/([^\]]+)\]').firstMatch(s);
    final code = match?.group(1);

    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Password lama salah.';
      case 'weak-password':
        return 'Password baru terlalu lemah (minimal 6 karakter).';
      case 'requires-recent-login':
        return 'Untuk keamanan, silakan logout lalu login lagi, kemudian coba lagi.';
      case 'network-request-failed':
        return 'Koneksi bermasalah. Cek internet kamu.';
      default:
        break;
    }

    if (s.startsWith('Exception: ')) return s.replaceFirst('Exception: ', '');
    if (s.contains('[firebase_auth/'))
      return 'Gagal mengganti password. Coba lagi.';
    return s.isEmpty ? 'Terjadi kesalahan. Coba lagi.' : s;
  }
}

// ================== CHANGE PASSWORD SHEET (AMAN) ==================

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  static const Color _primary = Color(0xFF0E2E72);
  static const Color _textDark = Color(0xFF1A2552);

  final oldC = TextEditingController();
  final newC = TextEditingController();
  final confirmC = TextEditingController();

  bool loading = false;
  String? err;

  @override
  void dispose() {
    oldC.dispose();
    newC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => err = null);

    final oldPass = oldC.text.trim();
    final newPass = newC.text.trim();
    final confirm = confirmC.text.trim();

    if (oldPass.isEmpty) {
      setState(() => err = 'Password lama wajib diisi.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => err = 'Password baru minimal 6 karakter.');
      return;
    }
    if (newPass != confirm) {
      setState(() => err = 'Konfirmasi password baru tidak sama.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      setState(() => err = 'Akun tidak valid. Silakan login ulang.');
      return;
    }

    try {
      setState(() => loading = true);

      // ✅ re-auth dulu
      final cred = EmailAuthProvider.credential(
        email: email,
        password: oldPass,
      );
      await user.reauthenticateWithCredential(cred);

      // ✅ update password
      await user.updatePassword(newPass);

      if (!mounted) return;
      Navigator.of(context).pop(); // tutup sheet dulu (AMAN)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diganti.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => err = AkunPage._mapAuthError(e.toString()));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: _primary),
                  SizedBox(width: 10),
                  Text(
                    'Ganti Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (err != null) ...[
                _ErrorBox(text: err!),
                const SizedBox(height: 10),
              ],

              _PassField(label: 'Password Lama', controller: oldC),
              const SizedBox(height: 10),
              _PassField(label: 'Password Baru', controller: newC),
              const SizedBox(height: 10),
              _PassField(
                label: 'Konfirmasi Password Baru',
                controller: confirmC,
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== UI Components ==================

class _ProfileCard extends StatelessWidget {
  final String nama;
  final String email;
  final String role;

  const _ProfileCard({
    required this.nama,
    required this.email,
    required this.role,
  });

  static const Color _primary = Color(0xFF0E2E72);
  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_rounded, color: _primary, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _muted,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  static const Color _primary = Color(0xFF0E2E72);
  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: _primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox({required this.text});

  static const Color _textDark = Color(0xFF1A2552);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _PassField({required this.label, required this.controller});

  @override
  State<_PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<_PassField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: IconButton(
          onPressed: () => setState(() => obscure = !obscure),
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }
}
