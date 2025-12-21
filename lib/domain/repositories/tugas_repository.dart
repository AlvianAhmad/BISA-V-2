import '../entities/tugas.dart';

abstract class TugasRepository {
  Stream<List<Tugas>> getTugas();
  Future<void> addTugas(Tugas tugas);
  Future<void> updateTugas(Tugas tugas);
  Future<void> deleteTugas(String id);
}
