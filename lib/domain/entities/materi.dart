class Materi {
  final String id;
  final String kelasId;
  final String kelasNama;
  final String judul;
  final String deskripsi;

  final String? fileUrl;
  final String? fileType; // pdf / docx / xlsx ...
  final String? fileName; // nama asli file
  final int? fileSize; // bytes (opsional)

  final DateTime createdAt;

  Materi({
    required this.id,
    required this.kelasId,
    required this.kelasNama,
    required this.judul,
    required this.deskripsi,
    this.fileUrl,
    this.fileType,
    this.fileName,
    this.fileSize,
    required this.createdAt,
  });
}
