import '../../entities/absensi.dart';
import '../../repositories/absensi_repository.dart';

class GetAbsensi {
  final AbsensiRepository repository;
  GetAbsensi(this.repository);

  Stream<List<Absensi>> call() {
    return repository.getAbsensi();
  }
}
