import '../../entities/tugas.dart';
import '../../repositories/tugas_repository.dart';

class GetTugas {
  final TugasRepository repository;
  GetTugas(this.repository);

  Stream<List<Tugas>> call() => repository.getTugas();
}
