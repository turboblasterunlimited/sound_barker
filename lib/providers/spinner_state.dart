import 'package:flutter/material.dart';

class SpinnerState with ChangeNotifier {
  bool barksLoading = false;
  bool songLoading = false;

  loadBarks() {
    barksLoading = true;
    notifyListeners();
  }

  stopLoading() {
    barksLoading = false;
    songLoading = false;
    notifyListeners();
  }

  loadSongs() {
    songLoading = true;
    notifyListeners();
  }
}
