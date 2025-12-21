import '../../repositories/tugas_repository.dart';

class DeleteTugas {
  final TugasRepository repository;
  DeleteTugas(this.repository);

  Future<void> call(String id) => repository.deleteTugas(id);
}
