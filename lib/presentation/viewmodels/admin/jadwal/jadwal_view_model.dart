import 'package:flutter/material.dart';
import '../../../../domain/entities/jadwal.dart';
import '../../../../domain/usecases/jadwal/add_jadwal.dart';
import '../../../../domain/usecases/jadwal/get_jadwal.dart';
import '../../../../domain/usecases/jadwal/update_jadwal.dart';
import '../../../../domain/usecases/jadwal/delete_jadwal.dart';

class JadwalViewModel extends ChangeNotifier {
  final GetJadwal getJadwal;
  final AddJadwal addJadwal;
  final UpdateJadwal updateJadwal;
  final DeleteJadwal deleteJadwal;

  JadwalViewModel({
    required this.getJadwal,
    required this.addJadwal,
    required this.updateJadwal,
    required this.deleteJadwal,
  });

  Stream<List<Jadwal>> jadwalStream() => getJadwal();

  Future<void> tambahJadwal(Jadwal jadwal) async {
    await addJadwal(jadwal);
  }
}
