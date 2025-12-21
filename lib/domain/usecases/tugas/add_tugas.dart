import '../../repositories/tugas_repository.dart';
import '../../entities/tugas.dart';

class AddTugas {
  final TugasRepository repository;

  AddTugas(this.repository);

  Future<void> call(Tugas tugas) {
    return repository.addTugas(tugas);
  }
}
