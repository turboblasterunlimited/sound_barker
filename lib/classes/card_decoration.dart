import 'dart:ui';
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
  Drawing(this.color);
}

class Typing {
  // textSpan includes color
  TextSpan textSpan;
  Offset offset;
  Typing(this.textSpan, this.offset);
}