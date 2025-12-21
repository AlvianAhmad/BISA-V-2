import '../../entities/jadwal.dart';
import '../../repositories/jadwal_repository.dart';

class UpdateJadwal {
  final JadwalRepository repository;

  UpdateJadwal(this.repository);

  Future<void> call(Jadwal jadwal) {
    return repository.updateJadwal(jadwal);
  }
}
