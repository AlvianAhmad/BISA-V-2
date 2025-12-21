import '../../entities/materi.dart';
import '../../repositories/materi_repository.dart';

class GetMateri {
  final MateriRepository repository;
  GetMateri(this.repository);

  Stream<List<Materi>> call(String kelasId) {
    return repository.getMateriByKelas(kelasId);
  }
}
