import 'package:flutter/material.dart';

class MahasiswaViewModel
    extends
        ChangeNotifier {
  int selectedIndex = 0;

  void changeTab(
    int index,
  ) {
    selectedIndex = index;
    notifyListeners();
  }
}
