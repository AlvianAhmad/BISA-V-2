import '../../entities/tugas.dart';
import '../../repositories/tugas_repository.dart';

class UpdateTugas {
  final TugasRepository repository;
  UpdateTugas(this.repository);

  Future<void> call(Tugas tugas) => repository.updateTugas(tugas);
}
