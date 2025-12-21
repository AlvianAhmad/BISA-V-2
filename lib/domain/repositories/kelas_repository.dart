import '../entities/kelas.dart';

abstract class KelasRepository {
  Stream<List<Kelas>> getKelas();
  Future<void> addKelas(Kelas kelas);
  Future<void> updateKelas(Kelas kelas);
  Future<void> deleteKelas(String id);
}
