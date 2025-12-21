import '../../repositories/absensi_repository.dart';

class DeleteAbsensi {
  final AbsensiRepository repository;
  DeleteAbsensi(this.repository);

  Future<void> call(String id) {
    return repository.deleteAbsensi(id);
  }
}
