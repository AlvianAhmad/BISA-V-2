import 'package:flutter/material.dart';
import '../../../../domain/entities/absensi.dart';
import '../../../../domain/usecases/absensi/add_absensi.dart';
import '../../../../domain/usecases/absensi/get_absensi.dart';
import '../../../../domain/usecases/absensi/update_absensi.dart';
import '../../../../domain/usecases/absensi/delete_absensi.dart';

class AbsensiViewModel extends ChangeNotifier {
  final GetAbsensi getAbsensi;
  final AddAbsensi addAbsensi;
  final UpdateAbsensi updateAbsensi;
  final DeleteAbsensi deleteAbsensi;

  AbsensiViewModel({
    required this.getAbsensi,
    required this.addAbsensi,
    required this.updateAbsensi,
    required this.deleteAbsensi,
  });

  Stream<List<Absensi>> absensiStream() {
    return getAbsensi();
  }

  Future<void> tambahAbsensi(Absensi absensi) async {
    await addAbsensi(absensi);
  }

  Future<void> updateAbsensiData(Absensi absensi) async {
    await updateAbsensi(absensi);
  }

  Future<void> hapusAbsensi(String id) async {
    await deleteAbsensi(id);
  }
}
