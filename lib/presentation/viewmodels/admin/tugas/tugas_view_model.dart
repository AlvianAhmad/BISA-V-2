import 'package:flutter/material.dart';
import '../../../../domain/entities/tugas.dart';
import '../../../../domain/usecases/tugas/add_tugas.dart';
import '../../../../domain/usecases/tugas/get_tugas.dart';
import '../../../../domain/usecases/tugas/update_tugas.dart';
import '../../../../domain/usecases/tugas/delete_tugas.dart';

class TugasViewModel extends ChangeNotifier {
  final GetTugas getTugas;
  final AddTugas addTugas;
  final UpdateTugas updateTugas;
  final DeleteTugas deleteTugas;

  TugasViewModel({
    required this.getTugas,
    required this.addTugas,
    required this.updateTugas,
    required this.deleteTugas,
  });

  Stream<List<Tugas>> tugasStream() => getTugas();

  Future<void> tambahTugas(Tugas tugas) async {
    await addTugas(tugas);
  }

  Future<void> hapusTugas(String id) async {
    await deleteTugas(id);
  }

  // ✅ Tambahkan method ini
  Future<void> updateTugasItem(Tugas tugas) async {
    await updateTugas(tugas);
    notifyListeners();
  }
}
