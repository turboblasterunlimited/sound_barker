import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/decorator.dart';

class CardDecoratorCanvas extends StatefulWidget {
  CardDecoratorCanvas();

  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  Decorator decoratorProvider;

  List<List<Offset>> _offSets = [];
  @override
  Widget build(BuildContext context) {
    decoratorProvider = Provider.of<Decorator>(context);

    return GestureDetector(
      onPanStart: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            _offSets.add(
              [Offset(details.localPosition.dx, details.localPosition.dy)],
            );
          });
      },
      onPanUpdate: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            _offSets.last.add(
              Offset(details.localPosition.dx, details.localPosition.dy),
            );
          });
      },
      onPanEnd: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            _offSets.last.add(_offSets.last.last);
          });
      },
      child: CustomPaint(
        painter: CardPainter(_offSets),
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
      ..color = Colors.pink;

    for (var mark in offsets) {
      for (var i = 0; i < mark.length - 1; i++) {
        if (mark[i] != null && mark[i + 1] != null)
          canvas.drawLine(mark[i], mark[i + 1], paint);
      }
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
