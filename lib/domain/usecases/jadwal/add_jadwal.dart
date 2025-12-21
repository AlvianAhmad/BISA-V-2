import '../../entities/jadwal.dart';
import '../../repositories/jadwal_repository.dart';

class AddJadwal {
  final JadwalRepository repository;

  AddJadwal(this.repository);

  Future<void> call(Jadwal jadwal) {
    return repository.addJadwal(jadwal);
  }
}
