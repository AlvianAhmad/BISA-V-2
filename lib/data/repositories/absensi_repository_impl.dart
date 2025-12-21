import '../../domain/entities/absensi.dart';
import '../../domain/repositories/absensi_repository.dart';
import '../datasources/absensi_remote_datasource.dart';

class AbsensiRepositoryImpl implements AbsensiRepository {
  final AbsensiRemoteDatasource datasource;

  AbsensiRepositoryImpl(this.datasource);

  @override
  Stream<List<Absensi>> getAbsensi() => datasource.getAbsensi();

  @override
  Future<void> addAbsensi(Absensi absensi) => datasource.addAbsensi(absensi);

  @override
  Future<void> updateAbsensi(Absensi absensi) =>
      datasource.updateAbsensi(absensi);

  @override
  Future<void> deleteAbsensi(String id) => datasource.deleteAbsensi(id);
}
