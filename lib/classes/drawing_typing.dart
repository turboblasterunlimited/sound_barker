import 'dart:ui';
import 'package:flutter/material.dart';

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