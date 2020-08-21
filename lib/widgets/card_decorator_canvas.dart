import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'package:K9_Karaoke/classes/drawing.dart';
import 'package:K9_Karaoke/classes/typing.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/karaoke_card_decoration_controller.dart';
import 'package:image/image.dart' as IMG;

class CardDecoratorCanvas extends StatefulWidget {
  final padding;
  CardDecoratorCanvas({this.padding});
  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

const List<int> frameDimensions = [656, 778];
const List<int> portraitDimensions = [512, 512];

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  KaraokeCardDecorationController karaokeCardDecorator;
  KaraokeCards cards;
  double screenWidth;
  List<Drawing> drawings;
  List<Typing> typings;

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

  void _handleAddNewDrawing(details) {
    if (karaokeCardDecorator.isDrawing)
      setState(() {
        karaokeCardDecorator.newDrawing();
        print("in karaoke card: ${karaokeCardDecorator.decoration.drawings}");
        print("Just drawings: $drawings");
        drawings.last.offsets.add(
          [_getOffset(details)],
        );
      });
  }

  void _handleUpdateDrawing(details) {
    if (karaokeCardDecorator.isDrawing)
      setState(() {
        drawings.last.offsets.last.add(
          _getOffset(details),
        );
      });
  }

  Offset _getOffset(details) {
    return Offset(details.localPosition.dx, details.localPosition.dy);
  }

  bool _inProximity(Offset existingXY, Offset touchedXY) {
    if ((existingXY.dx - touchedXY.dx).abs() < 100.0 &&
        (existingXY.dy - touchedXY.dy).abs() < 100.0) return true;
    return false;
  }

  bool _selectText(details) {
    // selecting text, moves the text to the end of the List
    var index = typings
        .indexWhere((text) => _inProximity(details.localPosition, text.offset));

    if (index == -1) return false;
    Typing selected = typings[index];
    typings.removeAt(index);
    setState(() => typings.add(selected));
    return true;
  }

  void _createNewTyping(details) {
    if (karaokeCardDecorator.isTyping) {
      typings.add(
        Typing(
          TextSpan(
            text: "",
            style: TextStyle(color: karaokeCardDecorator.color),
          ),
          _getOffset(details),
        ),
      );
    }
  }

  void _handleCreateOrSelectText(details) {
    if (karaokeCardDecorator.isTyping) {
      bool selected = _selectText(details);
      if (!selected) {
        _createNewTyping(details);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    print("building decorator canvas!");
    karaokeCardDecorator =
        Provider.of<KaraokeCardDecorationController>(context);
    cards = Provider.of<KaraokeCards>(context);
    karaokeCardDecorator.decoration = cards.current.decoration;
    drawings = karaokeCardDecorator.decoration.drawings;
    typings = karaokeCardDecorator.decoration.typings;
    screenWidth = MediaQuery.of(context).size.width;
    print("screenWidth: $screenWidth");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        print("Tapping canvas");
        _handleAddNewDrawing(details);
        _handleCreateOrSelectText(details);
      },
      onPanStart: (details) {
        print("Drawing....");
        _handleAddNewDrawing(details);
      },
      onPanUpdate: (details) {
        _handleUpdateDrawing(details);
      },
      onPanEnd: (details) {
        if (karaokeCardDecorator.isDrawing)
          setState(() {
            drawings.last.offsets.last
                .add(drawings.last.offsets.last.last);
          });
      },
      child: CustomPaint(
        painter: karaokeCardDecorator.cardPainter =
            CardPainter(drawings, typings, [cardWidth, cardHeight]),
        child: Container(
          height: cardHeight,
          width: cardWidth,
          child: karaokeCardDecorator.isTyping ? Positioned(
            top: typings.last.offset.dy,
            left: typings.last.offset.dx,
            child: Text(
              "XXX",
              style: TextStyle(fontSize: 30),
            ),
          ) : Center(),
        ),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  final drawings;
  final typings;
  final canvasDimensions;

  CardPainter(this.drawings, this.typings, this.canvasDimensions)
      : super();

  Future<Uint8List> _getArtwork(List aspect) async {
    var recorder = UI.PictureRecorder();
    var canvas = Canvas(recorder);
    paint(canvas, Size(canvasDimensions[0], canvasDimensions[1]));
    UI.Picture picture = recorder.endRecording();
    UI.Image image = await picture.toImage(
        canvasDimensions[0].round(), canvasDimensions[1].round());
    ByteData imageData = await image.toByteData(format: UI.ImageByteFormat.png);
    Uint8List test = imageData.buffer.asUint8List();
    IMG.Image imgImage = IMG.decodeImage(test);
    IMG.Image resized =
        IMG.copyResize(imgImage, width: aspect[0], height: aspect[1]);
    return IMG.encodePng(resized);
  }

  Future<Uint8List> _mergeArtWithFrame(IMG.Image art, String framePath) async {
    final frameBytes = await rootBundle.load(framePath);
    final frame = IMG.decodeImage(frameBytes.buffer
        .asUint8List(frameBytes.offsetInBytes, frameBytes.lengthInBytes));
    final mergedImage = IMG.Image(656, 787);
    IMG.copyInto(mergedImage, frame, blend: true);
    IMG.copyInto(mergedImage, art, blend: true);
    return IMG.encodePng(mergedImage);
  }

  Future<String> capturePNG(String uniqueId, [String framePath]) async {
    File file;
    Uint8List result;
    if (framePath == null) {
      result = await _getArtwork(portraitDimensions);
    } else {
      Uint8List artData = await _getArtwork(frameDimensions);
      final artImage = IMG.decodeImage(artData);
      result = await _mergeArtWithFrame(artImage, framePath);
    }
    file = await File("$myAppStoragePath/$uniqueId.png").writeAsBytes(result);
    return file.path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    for (var drawing in drawings) {
      paint.color = drawing.color;
      paint.strokeWidth = drawing.size / 2;
      for (var mark in drawing.offsets) {
        for (var i = 0; i < mark.length; i++) {
          canvas.drawCircle(mark[i], drawing.size / 2, paint);
        }
      }
    }

    Offset adjustOffset(Typing typing, Size tpSize) {
      Offset oldOffset = typing.offset;
      return Offset(oldOffset.dx - (tpSize.width / 2), oldOffset.dy);
    }

    for (var typing in typings) {
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
