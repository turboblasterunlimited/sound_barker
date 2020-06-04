import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/classes/drawing_typing.dart';
import 'package:song_barker/providers/card_decorator_provider.dart';

class CardDecoratorCanvas extends StatefulWidget {
  CardDecoratorCanvas();

  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  CardDecoratorProvider decoratorProvider;
  List<Drawing> allDrawings = [];
  List<Typing> allTyping = [];

  @override
  Widget build(BuildContext context) {
    decoratorProvider = Provider.of<CardDecoratorProvider>(context);
    decoratorProvider.allDrawings = allDrawings;
    decoratorProvider.allTyping = allTyping;

    return GestureDetector(
      onTapDown: (details) {
        // if (decoratorProvider.isTyping) {
        //   allTyping.add(
        //     Typing(
        //         TextSpan(
        //           text: "",
        //           style: TextStyle(color: decoratorProvider.color),
        //         ),
        //         Offset(details.localPosition.dx, details.localPosition.dy),),
        //   );
        // }
      },
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
        painter: CardPainter(allDrawings, allTyping),
        child: Container(),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final allDrawings;
  final allTyping;

  CardPainter(this.allDrawings, this.allTyping) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (var drawing in allDrawings) {
      paint.color = drawing.color;
      for (var mark in drawing.offsets) {
        for (var i = 0; i < mark.length - 1; i++) {
          if (mark[i] != null && mark[i + 1] != null)
            canvas.drawLine(mark[i], mark[i + 1], paint);
        }
      }
    }

    for (var typing in allTyping) {
      var tp = TextPainter(
          text: typing.textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, typing.offset);
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
