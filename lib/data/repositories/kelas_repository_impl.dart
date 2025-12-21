import '../../domain/entities/kelas.dart';
import '../../domain/repositories/kelas_repository.dart';
import '../datasources/kelas_remote_datasource.dart';

class KelasRepositoryImpl implements KelasRepository {
  final KelasRemoteDataSource remote;

  KelasRepositoryImpl(this.remote);

  @override
  Stream<List<Kelas>> getKelas() => remote.getKelas();

  @override
  Future<void> addKelas(Kelas kelas) => remote.addKelas(kelas);

  @override
  Future<void> updateKelas(Kelas kelas) => remote.updateKelas(kelas);

  @override
  Future<void> deleteKelas(String id) => remote.deleteKelas(id);
}
