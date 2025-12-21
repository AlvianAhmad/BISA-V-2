import '../../repositories/materi_repository.dart';

class DeleteMateri {
  final MateriRepository repository;
  DeleteMateri(this.repository);

  Future<void> call(String id) async {
    await repository.deleteMateri(id);
  }
}
