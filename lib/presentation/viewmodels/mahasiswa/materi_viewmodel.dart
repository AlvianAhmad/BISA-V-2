import 'package:flutter/material.dart';
import '../../../../data/datasources/materi_remote_datasource.dart';
import '../../../../domain/entities/materi.dart';

class MateriViewModel extends ChangeNotifier {
  final MateriRemoteDatasource ds;
  MateriViewModel(this.ds);

  Stream<List<Materi>> getMateriByKelas(String kelasId) {
    return ds.getMateriByKelas(kelasId);
  }
}
