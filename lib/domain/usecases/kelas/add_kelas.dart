import '../../entities/kelas.dart';
import '../../repositories/kelas_repository.dart';

class AddKelas {
  final KelasRepository repository;
  AddKelas(this.repository);

  Future<void> call(Kelas kelas) => repository.addKelas(kelas);
}
