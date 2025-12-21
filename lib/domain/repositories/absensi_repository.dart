import '../entities/absensi.dart';

abstract class AbsensiRepository {
  Stream<List<Absensi>> getAbsensi();
  Future<void> addAbsensi(Absensi absensi);
  Future<void> updateAbsensi(Absensi absensi);
  Future<void> deleteAbsensi(String id);
}
