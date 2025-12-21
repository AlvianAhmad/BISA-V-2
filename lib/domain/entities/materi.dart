class Materi {
  final String id;
  final String kelasId;
  final String kelasNama;
  final String judul;
  final String deskripsi;
  final String? fileUrl;
  final String? fileType;
  final DateTime createdAt;

  Materi({
    required this.id,
    required this.kelasId,
    required this.kelasNama,
    required this.judul,
    required this.deskripsi,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
  });
}
