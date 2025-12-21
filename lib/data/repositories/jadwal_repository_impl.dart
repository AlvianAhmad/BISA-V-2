import '../../domain/entities/jadwal.dart';
import '../../domain/repositories/jadwal_repository.dart';
import '../datasources/jadwal_remote_datasource.dart';

class JadwalRepositoryImpl implements JadwalRepository {
  final JadwalRemoteDataSource remoteDataSource;

  JadwalRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Jadwal>> getJadwal() {
    return remoteDataSource.getJadwal();
  }

  @override
  Future<void> addJadwal(Jadwal jadwal) {
    return remoteDataSource.addJadwal(jadwal);
  }

  @override
  Future<void> updateJadwal(Jadwal jadwal) {
    return remoteDataSource.updateJadwal(jadwal);
  }

  @override
  Future<void> deleteJadwal(String id) {
    return remoteDataSource.deleteJadwal(id);
  }
}
