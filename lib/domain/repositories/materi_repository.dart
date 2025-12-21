import '../entities/materi.dart';

abstract class MateriRepository {
  Stream<List<Materi>> getMateriByKelas(String kelasId);

  Future<void> addMateri(Materi materi);

  Future<void> updateMateri(Materi materi);

  Future<void> deleteMateri(String id);
}
