import 'package:flutter/material.dart';

class SpinnerState with ChangeNotifier {
  bool barksLoading = false;
  bool songLoading = false;
  bool signingIn = true;

  loadBarks() {
    barksLoading = true;
    notifyListeners();
  }

  stopLoading() {
    barksLoading = false;
    songLoading = false;
    signingIn = false;
    notifyListeners();
  }

  loadSongs() {
    songLoading = true;
    notifyListeners();
  }

  loadSignIn() {
    signingIn = true;
    notifyListeners();
  }
}
