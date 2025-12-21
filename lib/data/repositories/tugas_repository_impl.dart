import '../../domain/entities/tugas.dart';
import '../../domain/repositories/tugas_repository.dart';
import '../datasources/tugas_remote_datasource.dart';

class TugasRepositoryImpl implements TugasRepository {
  final TugasRemoteDataSource remote;

  TugasRepositoryImpl(this.remote);

  @override
  Stream<List<Tugas>> getTugas() => remote.getTugas();

  @override
  Future<void> addTugas(Tugas tugas) => remote.addTugas(tugas);

  @override
  Future<void> updateTugas(Tugas tugas) => remote.updateTugas(tugas);

  @override
  Future<void> deleteTugas(String id) => remote.deleteTugas(id);
}
