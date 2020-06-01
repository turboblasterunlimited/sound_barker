import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Decorator with ChangeNotifier {
  bool isDrawing = false;
  bool isTyping = false;
  Color color = Colors.black;

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

  void setColor(Color newColor) {
    this.color = newColor;
    notifyListeners();
  }
}
