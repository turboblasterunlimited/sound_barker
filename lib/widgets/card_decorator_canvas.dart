import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/classes/card_decoration.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';

class CardDecoratorCanvas extends StatefulWidget {
  CardDecoratorCanvas();

  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  KaraokeCardDecorator karaokeCardDecorator;
  List<Drawing> allDrawings = [];
  List<Typing> allTyping = [];

  @override
  Widget build(BuildContext context) {
    karaokeCardDecorator = Provider.of<KaraokeCardDecorator>(context);
    karaokeCardDecorator.allDrawings = allDrawings;
    karaokeCardDecorator.allTyping = allTyping;
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: (details) {
        // if (karaokeCardDecorator.isTyping) {
        //   allTyping.add(
        //     Typing(
        //         TextSpan(
        //           text: "",
        //           style: TextStyle(color: karaokeCardDecorator.color),
        //         ),
        //         Offset(details.localPosition.dx, details.localPosition.dy),),
        //   );
        // }
      },
      onPanStart: (details) {
        if (karaokeCardDecorator.isDrawing)
          setState(() {
            allDrawings.add(Drawing(karaokeCardDecorator.color));
            allDrawings.last.offsets.add(
              [Offset(details.localPosition.dx, details.localPosition.dy)],
            );
          });
      },
      onPanUpdate: (details) {
        if (karaokeCardDecorator.isDrawing)
          setState(() {
            allDrawings.last.offsets.last.add(
              Offset(details.localPosition.dx, details.localPosition.dy),
            );
          });
      },
      onPanEnd: (details) {
        if (karaokeCardDecorator.isDrawing)
          setState(() {
            allDrawings.last.offsets.last
                .add(allDrawings.last.offsets.last.last);
          });
      },
      child: CustomPaint(
        painter: karaokeCardDecorator.cardPainter = CardPainter(allDrawings, allTyping, screenWidth),
        child: Container(),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final allDrawings;
  final allTyping;
  final screenWidth;

  CardPainter(this.allDrawings, this.allTyping, this.screenWidth) : super();

  Future<String> capturePNG(String uniqueId) async {
    print("capturing png...");
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    paint(canvas, Size(screenWidth, screenWidth));
    var picture = recorder.endRecording();
    var image = await picture.toImage(512, 512);
    ByteData data = await image.toByteData(format: ImageByteFormat.png);

    final buffer = data.buffer;
    final file = await File("$myAppStoragePath/$uniqueId.png").writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return file.path;
    // return data.buffer.asUint8List();
  }

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

    Offset adjustOffset(Typing typing, Size tpSize) {
      Offset oldOffset = typing.offset;
      return Offset(oldOffset.dx - (tpSize.width / 2), oldOffset.dy);
    }

    for (var typing in allTyping) {
      var tp = TextPainter(
          textScaleFactor: 3.0,
          text: typing.textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, adjustOffset(typing, tp.size));
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
