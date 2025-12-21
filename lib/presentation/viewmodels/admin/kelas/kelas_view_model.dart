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
  }) {
    _init();
  }

  final List<Kelas> _kelasList = [];
  List<Kelas> get kelasList => _kelasList;

  void _init() {
    getKelas().listen((data) {
      _kelasList
        ..clear()
        ..addAll(data);
      notifyListeners();
    });
  }

  Future<void> tambahKelas(Kelas kelas) async {
    await addKelas(kelas);
  }

  Future<void> editKelas(Kelas kelas) async {
    await updateKelas(kelas);
  }

  Future<void> hapusKelas(String id) async {
    await deleteKelas(id);
  }
}
