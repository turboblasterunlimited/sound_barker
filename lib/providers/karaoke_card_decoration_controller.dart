import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
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

class KaraokeCardDecorationController with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  double size = 20;
  List<Drawing> allDrawings;
  List<Typing> allTyping;
  CardPainter cardPainter;
  double canvasLength;
  KaraokeCardDecorationController() {
    allDrawings = [];
    allTyping = [];
  }


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

  Offset get defaultTypingOffset {
    return Offset(canvasLength / 2, canvasLength - 30);
  }

  void initializeTyping(double length) {
    this.canvasLength = length;
    if (allTyping.isNotEmpty) return;
    final span = TextSpan(
      text: "",
      style: TextStyle(color: color, fontSize: size),
    );
    allTyping.add(Typing(
      span,
      defaultTypingOffset,
    ));
  }

  void updateLastTextSpan(newTextSpan) {
    if (allTyping.isEmpty)
      allTyping.add(Typing(newTextSpan, defaultTypingOffset));
    else
      allTyping.last.textSpan = newTextSpan;
  }

  void undoLast() {
    if (isDrawing) {
      if (allDrawings.isEmpty) return;
      print("Drawing length: ${allDrawings.length}");
      allDrawings.removeLast();
    }
    if (isTyping) {
      if (allTyping.isEmpty) return;
      print("Typing length: ${allTyping.length}");
      allTyping.removeLast();
    }
    notifyListeners();
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
    updateText();
    notifyListeners();
  }

  void setSize(double size) {
    this.size = size;
    updateText();
    notifyListeners();
  }

  void updateText([String newText]) {
    if (!isTyping) return;
    String text = newText ?? allTyping.last.textSpan.text;
    final newTextSpan =
        TextSpan(text: text, style: TextStyle(color: color, fontSize: size));
    updateLastTextSpan(newTextSpan);
  }
}
