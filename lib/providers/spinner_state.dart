import 'package:flutter/material.dart';

class SpinnerState with ChangeNotifier {
  bool isLoading = false;
  String loadingMessage = "Loading...";

  void startLoading([String message]) {
    if (message != null) loadingMessage = message;
    isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    loadingMessage = "Loading...";
    isLoading = false;
    notifyListeners();
  }
}
