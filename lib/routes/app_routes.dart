class AppRoutes {
  AppRoutes._();

  //====== AUTH ======
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';

  // ====== ADMIN ======
  static const String admin = '/admin';

  // ====== DOSEN =======
  static const String dosen = '/dosen';

  // ====== MAHASISWA SHELL (TAB) ======
  static const String mahasiswa = '/mahasiswa';
  static const mahasiswaBeranda = '/mahasiswa/beranda';
  static const mahasiswaKursus = '/mahasiswa/kursus';
  static const mahasiswaNotifikasi = '/mahasiswa/notifikasi';
  static const mahasiswaProfil = '/mahasiswa/profil';

  // ====== MAHASISWA FEATURES ======
  // Kalau nanti kamu mau halaman detail, bisa tambah di sini.
  static const String kursusEnroll = '/mahasiswa/kursus/enroll';
}
