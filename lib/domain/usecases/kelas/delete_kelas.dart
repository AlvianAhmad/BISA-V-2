import '../../repositories/kelas_repository.dart';

class DeleteKelas {
  final KelasRepository repository;
  DeleteKelas(this.repository);

  Future<void> call(String id) => repository.deleteKelas(id);
}
