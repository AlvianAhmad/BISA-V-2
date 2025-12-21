import 'package:flutter/material.dart';
import '../../../../domain/entities/materi.dart';
import '../../../../domain/usecases/materi/add_materi.dart';
import '../../../../domain/usecases/materi/get_materi.dart';
import '../../../../domain/usecases/materi/update_materi.dart';
import '../../../../domain/usecases/materi/delete_materi.dart';

class MateriViewModel extends ChangeNotifier {
  final GetMateri getMateri;
  final AddMateri addMateri;
  final UpdateMateri updateMateri;
  final DeleteMateri deleteMateri;

  MateriViewModel({
    required this.getMateri,
    required this.addMateri,
    required this.updateMateri,
    required this.deleteMateri,
  });

  Stream<List<Materi>> materiStream(String kelasId) {
    return getMateri(kelasId);
  }

  Future<void> tambahMateri(Materi m) async {
    await addMateri(m);
  }

  Future<void> editMateri(Materi m) async {
    await updateMateri(m);
  }

  Future<void> hapusMateri(String id) async {
    await deleteMateri(id);
  }
}
