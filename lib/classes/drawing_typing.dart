import 'dart:ui';
import 'package:flutter/material.dart';

class Drawing {
  List<List<Offset>> offsets = [];
  Color color;
  Drawing(this.color);
}

class Typing {
  TextSpan textSpan;
  Offset offset;
  Color color;
  Typing(this.textSpan, this.offset, this.color);
}