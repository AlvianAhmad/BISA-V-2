import '../../entities/absensi.dart';
import '../../repositories/absensi_repository.dart';

class UpdateAbsensi {
  final AbsensiRepository repository;
  UpdateAbsensi(this.repository);

  Future<void> call(Absensi absensi) {
    return repository.updateAbsensi(absensi);
  }
}
