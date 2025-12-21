import '../../entities/jadwal.dart';
import '../../repositories/jadwal_repository.dart';

class GetJadwal {
  final JadwalRepository repository;

  GetJadwal(this.repository);

  Stream<List<Jadwal>> call() {
    return repository.getJadwal();
  }
}
