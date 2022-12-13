import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'dart:ui';
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
  final width;
  final height;
  CardDecoratorCanvas(this.width, this.height);
  @override
  _CardDecoratorCanvasState createState() => _CardDecoratorCanvasState();
}

const List<int> frameDimensions = [656, 778];
const List<int> portraitDimensions = [512, 512];

class _CardDecoratorCanvasState extends State<CardDecoratorCanvas> {
  late KaraokeCardDecorationController decorationController;
  late KaraokeCards cards;
  Typing? selectedTyping;

  void _handleAddNewDrawing(details) {
    if (decorationController.isDrawing)
      setState(
        () {
          decorationController.newDrawing();
          // print("in karaoke card: ${decorationController.decoration.drawings}");
          // print("Just drawings: $drawings");
          drawings!.last.offsets.add(
            _getOffset(details),
          );
        },
      );
  }

  void _handleEndDrawing() {
    // if (decorationController.isDrawing)
    // setState(
    //   () => drawings.last.offsets.last.add(drawings.last.offsets.last.last),
    // );
  }

  void _handleUpdateDrawing(details) {
    if (decorationController.isDrawing)
      setState(() {
        drawings!.last.offsets.add(
          _getOffset(details),
        );
      });
  }

  Offset _getOffset(details) {
    return Offset(details.localPosition.dx, details.localPosition.dy);
  }

  bool _inProximity(Offset existingXY, Offset touchedXY) {
    if ((existingXY.dx - touchedXY.dx).abs() < 40.0 &&
        (existingXY.dy - touchedXY.dy).abs() < 40.0) return true;
    return false;
  }

  void _putTypingOnTop() {
    typings!.remove(selectedTyping);
    typings!.add(selectedTyping!);
  }

  bool _selectTyping(details) {
    // selecting text, moves the text to the end of the List
    getTyping(details);

    if (selectedTyping == null) return false;

    _putTypingOnTop();

    if (typings!.last.textSpan.text != "") {
      decorationController.updateTextField();
      decorationController.updateSizeAndColor(selectedTyping);
    }
    return true;
  }

  void getTyping(details) {
    var touchedOffset =
        Offset(details.localPosition.dx, details.localPosition.dy);
    for (var typing in typings!) {
      if (_inProximity(typing.offset, touchedOffset)) {
        selectedTyping = typing;
        return;
      }
    }
    // wont get here if inProximity returns true
    selectedTyping = null;
  }

  void _createNewTyping(details) {
    if (decorationController.isTyping) {
      typings!.add(
        Typing(
          TextSpan(
            text: "",
            style: TextStyle(color: decorationController.color),
          ),
          _getOffset(details),
        ),
      );
      decorationController.clearTextField();
    }
  }

  void _handleCreateOrSelectTyping(details) {
    if (!decorationController.isTyping) return;
    bool selected = _selectTyping(details);
    if (!selected) _createNewTyping(details);
    decorationController.focusNode!.requestFocus();
  }

  void _handleStartDragTyping(DragStartDetails details) {
    if (!decorationController.isTyping) return;
    getTyping(details);
  }

  void _handleDragTyping(DragUpdateDetails details) {
    if (!decorationController.isTyping) return;
    if (selectedTyping == null) return;

    var touchedOffset =
        Offset(details.localPosition.dx, details.localPosition.dy);

    setState(() => selectedTyping!.offset = touchedOffset);
  }

  void _handleEndDragTyping() {
    setState(() => selectedTyping = null);
  }

  List<Drawing>? get drawings {
    return decorationController.decoration?.drawings;
  }

  List<Typing>? get typings {
    return decorationController.decoration?.typings;
  }

  @override
  Widget build(BuildContext context) {
    print("building decorator canvas!");
    decorationController =
        Provider.of<KaraokeCardDecorationController>(context);
    cards = Provider.of<KaraokeCards>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        print("Drawing....");
        _handleAddNewDrawing(details);
        _handleStartDragTyping(details);
      },
      onPanUpdate: (details) {
        _handleUpdateDrawing(details);
        _handleDragTyping(details);
      },
      onPanEnd: (details) {
        _handleEndDrawing();
        _handleEndDragTyping();
      },
      onTapUp: (details) {
        print("Tapping canvas");
        _handleAddNewDrawing(details);
        _handleCreateOrSelectTyping(details);
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: decorationController.cardPainter =
                CardPainter(drawings, typings, [widget.width, widget.height]),
            child: Container(
              height: widget.height,
              width: widget.width,
              child: Center(),
            ),
          ),
          CustomPaint(
            painter: CaretPainter(decorationController),
            child: Container(
              height: widget.height,
              width: widget.width,
              child: Center(),
            ),
          ),
        ],
      ),
    );
  }
}

class CaretPainter extends CustomPainter {
  final KaraokeCardDecorationController decorationController;

  CaretPainter(this.decorationController) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    final circlePaint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.blue;

    Offset caretOffset(Typing typing) {
      var tp = TextPainter(
          textScaleFactor: 3.0,
          text: typing.textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);

      tp.layout();

      Offset oldOffset = typing.offset;
      return Offset(oldOffset.dx + (tp.size.width / 2), oldOffset.dy);
      // return Offset(oldOffset.dx, oldOffset.dy);
    }

    if (!decorationController.isTyping) return;

    if (decorationController.decoration!.typings.isEmpty)
      decorationController.addTyping();

    Typing lastTyping = decorationController.decoration!.typings.last;
    var size = lastTyping.textSpan.text == ""
        ? decorationController.size
        : lastTyping.textSpan.style!.fontSize;
    //paint drag thumb
    canvas.drawOval(
        Rect.fromCenter(center: lastTyping.offset, width: size!, height: size),
        circlePaint);
    //paint caret
    if (decorationController.paintCarat) {
      var offset = caretOffset(lastTyping);
      canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, 5, size * 4), paint);
    }
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}

class CardPainter extends CustomPainter {
  final drawings;
  final typings;
  final canvasDimensions;

  CardPainter(this.drawings, this.typings, this.canvasDimensions) : super();

  Future<Uint8List> _getArtwork(List aspect) async {
    var recorder = UI.PictureRecorder();
    var canvas = Canvas(recorder);
    paint(canvas, Size(canvasDimensions[0], canvasDimensions[1]));
    UI.Picture picture = recorder.endRecording();
    UI.Image image = await picture.toImage(
        canvasDimensions[0].round(), canvasDimensions[1].round());
    ByteData imageData =
        (await image.toByteData(format: UI.ImageByteFormat.png))!;
    Uint8List test = imageData.buffer.asUint8List();
    IMG.Image imgImage = IMG.decodeImage(test)!;
    IMG.Image resized =
        IMG.copyResize(imgImage, width: aspect[0], height: aspect[1]);
    return IMG.encodePng(resized, level: 0) as Uint8List;
  }

  Future<Uint8List> _mergeArtWithFrame(IMG.Image art, String framePath) async {
    final frameBytes = await rootBundle.load(framePath);
    final frame = IMG.decodeImage(frameBytes.buffer
        .asUint8List(frameBytes.offsetInBytes, frameBytes.lengthInBytes));
    final mergedImage = IMG.Image(656, 778);
    IMG.copyInto(mergedImage, frame!, blend: true);
    IMG.copyInto(mergedImage, art, blend: true);
    return IMG.encodePng(mergedImage, level: 1) as Uint8List;
  }

  Future<String> capturePNG(String uniqueId, [String? framePath]) async {
    File file;
    Uint8List result;
    if (framePath == null) {
      result = await _getArtwork(portraitDimensions);
    } else {
      Uint8List artData = await _getArtwork(frameDimensions);
      final artImage = IMG.decodeImage(artData);
      result = await _mergeArtWithFrame(artImage!, framePath);
    }
    file = await File("$myAppStoragePath/$uniqueId.png").writeAsBytes(result);
    return file.path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    for (var drawing in drawings) {
      paint.color = drawing.color;
      paint.strokeWidth = drawing.size / 2;
      for (int i = 0; i < drawing.offsets.length; i++) {
        var mark = drawing.offsets;
        if (i == mark.length - 1) {
          canvas.drawPoints(PointMode.points, [mark[i]], paint);
        } else {
          canvas.drawLine(mark[i], mark[i + 1], paint);
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
