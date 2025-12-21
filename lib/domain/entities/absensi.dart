class Absensi {
  final String id;
  final String judul;
  final String kelas;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final bool aktif;

  Absensi({
    required this.id,
    required this.judul,
    required this.kelas,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.aktif,
  });

  Absensi copyWith({
    String? judul,
    String? kelas,
    DateTime? tanggal,
    String? jamMulai,
    String? jamSelesai,
    bool? aktif,
  }) {
    return Absensi(
      id: id,
      judul: judul ?? this.judul,
      kelas: kelas ?? this.kelas,
      tanggal: tanggal ?? this.tanggal,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      aktif: aktif ?? this.aktif,
    );
  }
}
