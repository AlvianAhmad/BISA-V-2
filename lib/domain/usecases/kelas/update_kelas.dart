import '../../entities/kelas.dart';
import '../../repositories/kelas_repository.dart';

class UpdateKelas {
  final KelasRepository repository;
  UpdateKelas(this.repository);

  Future<void> call(Kelas kelas) => repository.updateKelas(kelas);
}
