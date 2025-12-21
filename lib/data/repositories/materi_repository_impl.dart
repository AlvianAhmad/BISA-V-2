import '../../domain/entities/materi.dart';
import '../../domain/repositories/materi_repository.dart';
import '../datasources/materi_remote_datasource.dart';

class MateriRepositoryImpl implements MateriRepository {
  final MateriRemoteDatasource remote;

  MateriRepositoryImpl(this.remote);

  @override
  Stream<List<Materi>> getMateriByKelas(String kelasId) {
    return remote.getMateriByKelas(kelasId);
  }

  @override
  Future<void> addMateri(Materi materi) async {
    await remote.addMateri(materi);
  }

  @override
  Future<void> updateMateri(Materi materi) async {
    await remote.updateMateri(materi);
  }

  @override
  Future<void> deleteMateri(String id) async {
    await remote.deleteMateri(id);
  }
}
