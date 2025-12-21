import '../../entities/kelas.dart';
import '../../repositories/kelas_repository.dart';

class GetKelas {
  final KelasRepository repository;

  GetKelas(this.repository);

  Stream<List<Kelas>> call() => repository.getKelas();
}
