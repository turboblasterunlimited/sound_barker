import 'package:K9_Karaoke/classes/decoration.dart';
import 'package:K9_Karaoke/classes/drawing.dart';
import 'package:K9_Karaoke/classes/typing.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KaraokeCardDecorationController with ChangeNotifier {
  bool isDrawing = true;
  bool isTyping = false;
  Color color = Colors.black;
  double size = 20;
  CardDecoration decoration;
  CardPainter cardPainter;
  double canvasLength;
  KaraokeCardDecorationController();

  void newDrawing() {
    decoration.drawings.add(Drawing(color, size));
  }

  void reset() {
    decoration.drawings.clear();
    decoration.typings.clear();
    notifyListeners();
  }

  Offset get defaultTypingOffset {
    return Offset(canvasLength / 2, canvasLength - 30);
  }

  void setDecoration(cardDecoration, screenWidth) {
    decoration = cardDecoration;
    _initializeTyping(screenWidth);
    // notifyListeners();
  }

  void _initializeTyping(double length) {
    this.canvasLength = length;
    if (decoration.typings.isNotEmpty) return;
    final span = TextSpan(
      text: "",
      style: TextStyle(color: color, fontSize: size),
    );
    decoration.typings.add(Typing(
      span,
      defaultTypingOffset,
    ));
    print("decoration.typings now not empty");
  }

  void updateLastTextSpan(newTextSpan) {
    if (decoration.typings.isEmpty)
      decoration.typings.add(Typing(newTextSpan, defaultTypingOffset));
    else
      decoration.typings.last.textSpan = newTextSpan;
  }

  void undoLast() {
    if (isDrawing) {
      if (decoration.drawings.isEmpty) return;
      print("Drawing length: ${decoration.drawings.length}");
      decoration.drawings.removeLast();
    }
    if (isTyping) {
      if (decoration.typings.isEmpty) return;
      print("Typing length: ${decoration.typings.length}");
      decoration.typings.removeLast();
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
    String text = newText ?? decoration.typings.last.textSpan.text;
    final newTextSpan =
        TextSpan(text: text, style: TextStyle(color: color, fontSize: size));
    updateLastTextSpan(newTextSpan);
  }
}
