abstract class AuthRepository {
  // ===== LOGIN =====
  Future<String> login(String email, String password);
  Future<String> loginWithGoogle();

  // ===== REGISTER MAHASISWA =====
  Future<void> registerMahasiswa({
    required String nama,
    required String username,
    required String nim,
    required String programStudi,
    required String email,
    required String password,
  });

  // ===== RESET & ROLE =====
  Future<void> resetPassword(String email);
  Future<String> getRole(String uid);

  // ===== ADMIN CREATE USER =====
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> data,
  });
}
