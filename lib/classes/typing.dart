import 'package:flutter/material.dart';

class Typing {
  // textSpan includes color
  TextSpan textSpan;
  Offset offset;
  Typing(this.textSpan, this.offset);

  bool isEmpty() {
    return textSpan.text!.isEmpty;
  }
}
