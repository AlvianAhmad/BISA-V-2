import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFirebaseDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ================= REGISTER MAHASISWA (USER DAFTAR SENDIRI) =================
  Future<void> registerMahasiswa({
    required String nama,
    required String username,
    required String nim,
    required String programStudi,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'nama': nama,
      'username': username,
      'nim': nim,
      'programStudi': programStudi,
      'email': email,
      'role': 'mahasiswa',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= ADMIN CREATE USER (MAHASISWA / DOSEN) =================
  Future<void> createUserByAdmin({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> data,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      ...data,
    });
  }

  // ================= LOGIN EMAIL =================
  Future<String> loginWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user!.uid;
  }

  // ================= GET EMAIL BY USERNAME =================
  Future<String?> getEmailByUsername(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.get('email');
  }

  // ================= GOOGLE SIGN IN (ANDROID) =================
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Login Google dibatalkan');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    final User user = userCredential.user!;

    // ================= SIMPAN USER JIKA BARU =================
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': 'mahasiswa',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user.uid;
  }

  // ================= RESET PASSWORD =================
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ================= GET ROLE =================
  Future<String> getRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.get('role');
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
