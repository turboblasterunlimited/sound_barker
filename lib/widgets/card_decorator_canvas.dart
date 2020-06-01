import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/decorator.dart';

class Drawing {
  List<List<Offset>> offsets = [];
  Color color;
  Drawing(this.color);
}

class CardDecoratorCanvas extends StatefulWidget {
  CardDecoratorCanvas();

  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  Decorator decoratorProvider;
  List<Drawing> allDrawings = [];
  
  @override
  Widget build(BuildContext context) {
    decoratorProvider = Provider.of<Decorator>(context);

    return GestureDetector(
      onPanStart: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            allDrawings.add(Drawing(decoratorProvider.color));
            allDrawings.last.offsets.add(
              [Offset(details.localPosition.dx, details.localPosition.dy)],
            );
          });
      },
      onPanUpdate: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            allDrawings.last.offsets.last.add(
              Offset(details.localPosition.dx, details.localPosition.dy),
            );
          });
      },
      onPanEnd: (details) {
        if (decoratorProvider.isDrawing)
          setState(() {
            allDrawings.last.offsets.last
                .add(allDrawings.last.offsets.last.last);
          });
      },
      child: CustomPaint(
        painter: CardPainter(allDrawings),
        child: Container(),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final allDrawings;

  CardPainter(this.allDrawings) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.black;

    for (var drawing in allDrawings) {
      paint.color = drawing.color;
      for (var mark in drawing.offsets) {
        for (var i = 0; i < mark.length - 1; i++) {
          if (mark[i] != null && mark[i + 1] != null)
            canvas.drawLine(mark[i], mark[i + 1], paint);
        }
      }
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
