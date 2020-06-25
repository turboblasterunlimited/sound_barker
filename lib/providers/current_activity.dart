import 'package:flutter/foundation.dart';

class CurrentActivity with ChangeNotifier {
  bool cardCreation = false;
  bool songLibrary = false;
  bool barkLibrary = false;

  void startCreateCard() {
    cardCreation = true;
    songLibrary = false;
    barkLibrary = false;
    notifyListeners();
  }

  void startSongLibrary() {
    cardCreation = false;
    songLibrary = true;
    barkLibrary = false;
    notifyListeners();
  }

  void startBarkLibrary() {
    cardCreation = false;
    songLibrary = false;
    barkLibrary = true;
    notifyListeners();
  }
}
