import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/classes/card_decoration.dart';

class KaraokeCardDecorator with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  List<Drawing> allDrawings;
  List<Typing> allTyping;
  var cardPainter;

  setPainter(painter) {
    cardPainter = painter;
    notifyListeners();
    return painter;
  }

  void saveCanvasToFile() {
    cardPainter?.toPNG();
  }
  void updateLastTextSpan(newTextSpan) {
    allTyping.last.textSpan = newTextSpan;
    print("Typing length: ${allDrawings.length}");
    notifyListeners();
  }

  void undoLast() {
    if (isDrawing) {
      if (allDrawings.isEmpty) return;
      print("Drawing length: ${allDrawings.length}");
      allDrawings.removeLast();
      notifyListeners();
    }
    if (isTyping) {
      if (allTyping.isEmpty) return;
      print("Typing length: ${allTyping.length}");
      allTyping.removeLast();
      notifyListeners();
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