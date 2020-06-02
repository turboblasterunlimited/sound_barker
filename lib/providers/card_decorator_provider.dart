import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:song_barker/classes/drawing.dart';

class CardDecoratorProvider with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  List<Drawing> allDrawings;

  void undoLast() {
    if (allDrawings.isEmpty) return;
    allDrawings.removeLast();
  }

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

  void setColor(Color newColor) {
    this.color = newColor;
    notifyListeners();
  }
}
