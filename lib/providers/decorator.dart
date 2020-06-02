import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Decorator with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  bool isErasing = false;
  Color color = Colors.black;

  void startDrawing() {
    isDrawing = true;
    isTyping = false;
    isErasing = false;
    notifyListeners();
  }

  void startErasing() {
    isDrawing = false;
    isTyping = false;
    isErasing = true;
    notifyListeners();
  }

  void startTyping() {
    isTyping = true;
    isDrawing = false;
    isErasing = false;
    notifyListeners();
  }

  void setColor(Color newColor) {
    this.color = newColor;
    notifyListeners();
  }
}
