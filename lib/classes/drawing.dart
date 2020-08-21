import 'package:flutter/material.dart';

class Drawing {
  List<List<Offset>> offsets = [];
  Color color;
  double size;
  Drawing(this.color, this.size);
}