import 'dart:ui';

import 'package:flutter/material.dart';

class CardDecoratorCanvas extends StatefulWidget {
  CardDecoratorCanvas();

  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  bool _isDrawing = false;
  bool _isTyping = false;
  List<Offset> _offSets;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CardPainter(_offSets),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _offSets.add(
                Offset(details.localPosition.dx, details.localPosition.dy));
          });
        },
        onPanUpdate: (details) {
          print("drawing");
          setState(() {
            _offSets.add(
                Offset(details.localPosition.dx, details.localPosition.dy));
          });
        },
        onPanEnd: (details) {},
        child: Container(),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final offsets;

  CardPainter(this.offsets) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    for (var i = 0; i < offsets.length; i++) {
      if (offsets[i] != null && offsets[i + 1] != null)
        canvas.drawLine(offsets[i], offsets[i + 1], paint);

      if (offsets[i] != null && offsets[i + 1] == null)
        canvas.drawPoints(PointMode.points, offsets[i], paint);
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
