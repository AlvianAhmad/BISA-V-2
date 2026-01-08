class Kelas {
  final String id;
  final String nama;
  final String jurusan;
  final String semester;
  final String dosen;

  Kelas({
    required this.id,
    required this.nama,
    required this.jurusan,
    required this.semester,
    this.dosen = '',
  });
}
