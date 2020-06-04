import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:song_barker/classes/drawing_typing.dart';

class CardDecoratorProvider with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  List<Drawing> allDrawings;
  List<Typing> allTyping;

  void updateLastTextSpan(newTextSpan) {
    allTyping.last.textSpan = newTextSpan;
    notifyListeners();
  }

  void undoLast() {
    if (isDrawing) {
      if (allDrawings.isEmpty) return;
      allDrawings.removeLast();
    }
    if (isTyping) {
      if (allTyping.isEmpty) return;
      allDrawings.removeLast();
    }
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
    if (isTyping) {
      final text = allTyping.last.textSpan.text;
      final newTextSpan = TextSpan(text: text, style: TextStyle(color: color));
      updateLastTextSpan(newTextSpan);
    }
  }
}
