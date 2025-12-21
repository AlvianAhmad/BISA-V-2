import '../../repositories/jadwal_repository.dart';

class DeleteJadwal {
  final JadwalRepository repository;

  DeleteJadwal(this.repository);

  Future<void> call(String id) {
    return repository.deleteJadwal(id);
  }
}
