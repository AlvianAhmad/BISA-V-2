import 'package:flutter/material.dart';
import '../../../../domain/entities/kelas.dart';
import '../../../../domain/usecases/kelas/add_kelas.dart';
import '../../../../domain/usecases/kelas/get_kelas.dart';
import '../../../../domain/usecases/kelas/update_kelas.dart';
import '../../../../domain/usecases/kelas/delete_kelas.dart';

class KelasViewModel extends ChangeNotifier {
  final GetKelas getKelas;
  final AddKelas addKelas;
  final UpdateKelas updateKelas;
  final DeleteKelas deleteKelas;

  KelasViewModel({
    required this.getKelas,
    required this.addKelas,
    required this.updateKelas,
    required this.deleteKelas,
  });

  Stream<List<Kelas>> kelasStream() => getKelas();

  Future<void> tambahKelas(Kelas kelas) async {
    await addKelas(kelas);
    notifyListeners();
  }

  Future<void> hapusKelas(String id) async {
    await deleteKelas(id);
    notifyListeners();
  }

  Future<void> updateKelasData(Kelas kelas) async {
    await updateKelas(kelas);
    notifyListeners();
  }
}
