import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:song_barker/tools/app_storage_path.dart';

class Decorator with ChangeNotifier {
  bool isDrawing = false;
  bool isTyping = false;

  void startDrawing() {
    isDrawing = true;
    isTyping = false;
    notifyListeners();
  }

  void startTyping() {
    isTyping = true;
    isDrawing = false;
    notifyListeners();
  }

  void stopTyping() {
    isTyping = false;
    notifyListeners();
  }

  void stopDrawing() {
    isDrawing = false;
    notifyListeners();
  }
}
