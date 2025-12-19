import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_firebase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  // ================= LOGIN =================
  @override
  Future<String> login(String email, String password) =>
      datasource.loginWithEmail(email, password);

  @override
  Future<String> loginWithGoogle() => datasource.signInWithGoogle();

  // ================= REGISTER MAHASISWA =================
  @override
  Future<void> registerMahasiswa({
    required String nama,
    required String username,
    required String nim,
    required String programStudi,
    required String email,
    required String password,
  }) async {
    await datasource.registerMahasiswa(
      nama: nama,
      username: username,
      nim: nim,
      programStudi: programStudi,
      email: email,
      password: password,
    );
  }

  // ================= RESET & ROLE =================
  @override
  Future<void> resetPassword(String email) => datasource.resetPassword(email);

  @override
  Future<String> getRole(String uid) => datasource.getRole(uid);

  // ================= ADMIN CREATE USER =================
  @override
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> data,
  }) async {
    await datasource.createUserByAdmin(
      email: email,
      password: password,
      role: role,
      data: data,
    );
  }
}
