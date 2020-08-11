import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CardDecoration {
  String fileId;
  Drawing drawing;
  Typing typing;
  CardDecoration({this.fileId, this.drawing, this.typing});
}

class Drawing {
  List<List<Offset>> offsets = [];
  Color color;
  double size;
  Drawing(this.color, this.size);
}

class Typing {
  // textSpan includes color
  TextSpan textSpan;
  Offset offset;
  Typing(this.textSpan, this.offset);
}

class KaraokeCardDecorator with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  double size = 20;
  List<Drawing> allDrawings;
  List<Typing> allTyping;
  var cardPainter;

  void newDrawing() {
    allDrawings.add(Drawing(color, size));
  }

  bool isEmpty() {
    return allDrawings.isEmpty && allTyping.isEmpty;
  }

  void reset() {
    allDrawings.clear();
    allTyping.clear();
    notifyListeners();
  }

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
    updateText();
  }

  void setSize(double size) {
    this.size = size;
    notifyListeners();
    updateText();
  }

  void updateText() {
    if (isTyping) {
      final text = allTyping.last.textSpan.text;
      final newTextSpan =
          TextSpan(text: text, style: TextStyle(color: color, fontSize: size));
      updateLastTextSpan(newTextSpan);
    }
  }
}
