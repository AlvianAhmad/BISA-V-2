import '../../entities/absensi.dart';
import '../../repositories/absensi_repository.dart';

class AddAbsensi {
  final AbsensiRepository repository;
  AddAbsensi(this.repository);

  Future<void> call(Absensi absensi) {
    return repository.addAbsensi(absensi);
  }
}
