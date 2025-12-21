import '../entities/jadwal.dart';

abstract class JadwalRepository {
  Stream<List<Jadwal>> getJadwal();
  Future<void> addJadwal(Jadwal jadwal);
  Future<void> updateJadwal(Jadwal jadwal);
  Future<void> deleteJadwal(String id);
}
