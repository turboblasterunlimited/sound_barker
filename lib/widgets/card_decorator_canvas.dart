import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decorator.dart';
import 'package:image/image.dart' as IMG;

class CardDecoratorCanvas extends StatefulWidget {
  final padding;
  CardDecoratorCanvas({this.padding});
  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

const List<int> frameDimensions = [656, 778];

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  KaraokeCardDecorator karaokeCardDecorator;
  KaraokeCards cards;
  double screenWidth;

  double get cardHeight {
    if (cards.current.framePath != null) {
      return screenWidth / frameDimensions[0] * frameDimensions[1];
    } else {
      return screenWidth - (widget.padding * 2);
    }
  }

  double get cardWidth {
    if (cards.current.framePath != null) {
      return screenWidth;
    } else {
      return screenWidth - (widget.padding * 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building decorator canvas!");
    karaokeCardDecorator = Provider.of<KaraokeCardDecorator>(context);
    cards = Provider.of<KaraokeCards>(context);
    final allDrawings = karaokeCardDecorator.allDrawings;
    final allTyping = karaokeCardDecorator.allTyping;
    screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        print("Tapping canvas");
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
        print("Drawing....");
        if (karaokeCardDecorator.isDrawing)
          setState(() {
            karaokeCardDecorator.newDrawing();
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
        painter: karaokeCardDecorator.cardPainter =
            CardPainter(allDrawings, allTyping, screenWidth),
        child: Container(height: cardHeight, width: cardWidth),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final allDrawings;
  final allTyping;
  final screenWidth;

  CardPainter(this.allDrawings, this.allTyping, this.screenWidth) : super();

  Future<ByteData> _getArtwork(List aspect) async {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    paint(canvas, Size(aspect[0], aspect[1]));
    var picture = recorder.endRecording();
    var image = await picture.toImage(aspect[0], aspect[1]);
    return await image.toByteData(format: ImageByteFormat.png);
  }

  Future<Uint8List> _mergeArtWithFrame(IMG.Image art, String framePath) async {
    final frameBytes = await rootBundle.load(framePath);
    final frame = IMG.decodeImage(frameBytes.buffer.asUint8List());
    final mergedImage = IMG.Image(656, 787);
    IMG.copyInto(mergedImage, frame, blend: false);
    IMG.copyInto(mergedImage, art, blend: false);
    return IMG.encodePng(mergedImage);
  }

  Future<String> capturePNG(String uniqueId, [String framePath]) async {
    File file;
    Uint8List result;
    if (framePath == null) {
      ByteData artData = await _getArtwork([512, 512]);
      final buffer = artData.buffer;
      result = buffer.asUint8List(artData.offsetInBytes, artData.lengthInBytes);
    } else {
      ByteData artData = await _getArtwork([656, 778]);
      final artImage = IMG.decodeImage(artData.buffer.asUint8List());
      result = await _mergeArtWithFrame(artImage, framePath);
    }
    file = await File("$myAppStoragePath/$uniqueId.png").writeAsBytes(result);
    return file.path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (var drawing in allDrawings) {
      paint.color = drawing.color;
      paint.strokeWidth = drawing.size;
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
