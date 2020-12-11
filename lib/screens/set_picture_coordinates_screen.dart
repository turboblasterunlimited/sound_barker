import 'dart:typed_data';
import 'package:K9_Karaoke/globals.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/card_progress_bar.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/photo_name_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:image/image.dart' as IMG;
import 'package:flutter/painting.dart';
import 'dart:ui' as ui;

import '../providers/pictures.dart';
import '../providers/image_controller.dart';
import '../services/rest_api.dart';

double canvasLength;
double imageSizeDifference;

double magOffset = 80;
int magImageSize = 550;

class SetPictureCoordinatesScreen extends StatefulWidget {
  Picture newPicture;
  bool editing;
  bool isNamed;
  bool coordinatesSet;

  SetPictureCoordinatesScreen(this.newPicture, {this.editing = false}) {
    this.isNamed = editing ? true : false;
    this.coordinatesSet = editing ? true : false;
  }

  @override
  _SetPictureCoordinatesScreenState createState() =>
      _SetPictureCoordinatesScreenState();
}

class _SetPictureCoordinatesScreenState
    extends State<SetPictureCoordinatesScreen> {
  Map<String, List<double>> canvasCoordinates = {};
  double middle;
  IMG.Image imageData;
  Uint8List imageDataBytes;
  // Canvas pixels
  List<double> touchedXY = [0.0, 0.0];
  ui.Image magnifiedImage;
  // for moving all coordinates with mouth center.
  List<double> mouthStartingPosition = [0.0, 0.0];
  List<double> mouthLeftStartingPosition = [0.0, 0.0];
  List<double> mouthRightStartingPosition = [0.0, 0.0];
  bool grabbing = false;
  Map<String, List<double>> grabPoint = {};
  String _instructionalText = "";

  Pictures pictures;
  ImageController imageController;
  KaraokeCards cards;
  KaraokeCard card;
  CurrentActivity currentActivity;
  bool _isFirstBuild = true;

  String _getInstructionalText() {
    return widget.newPicture.isNamed ? "SET FACE" : "NAME PHOTO";
  }

  @override
  void initState() {
    print("init state set picture coordinates screen");
    super.initState();
  }

  _puppetXtoCanvasX(x) {
    double offset = x * middle * 2;
    return offset + middle;
  }

  _puppetYtoCanvasY(y) {
    double offset = y * middle * 2;
    if (offset < 0)
      offset = offset.abs();
    else
      offset = 0 - offset;
    return offset + middle;
  }

  void setCanvasCoordinatesFromPicture() {
    widget.newPicture.coordinates.forEach((key, xy) {
      canvasCoordinates[key] = [
        _puppetXtoCanvasX(xy[0]),
        _puppetYtoCanvasY(xy[1])
      ];
    });
  }

  void resetCanvasCoordinates() {
    defaultFaceCoordinates.forEach((key, xy) {
      canvasCoordinates[key] = [
        _puppetXtoCanvasX(xy[0]),
        _puppetYtoCanvasY(xy[1])
      ];
    });
  }

  Map<String, List<double>> getCoordinatesForCanvas() {
    if (canvasCoordinates.length != 0) return canvasCoordinates;
    setCanvasCoordinatesFromPicture();
    return canvasCoordinates;
  }

  saveCanvasToPictureCoordinates() {
    _canvasXToPuppetX(x) {
      double centered = x - middle;
      return centered / middle / 2;
    }

    _canvasYToPuppetY(y) {
      double centered = y - middle;
      if (centered < 0)
        centered = centered.abs();
      else
        centered = 0 - centered;
      return centered / middle / 2;
    }

    setState(() {
      canvasCoordinates.forEach((String key, List xy) {
        widget.newPicture.coordinates[key] = [
          _canvasXToPuppetX(xy[0]),
          _canvasYToPuppetY(xy[1])
        ];
      });
    });
  }

  bool _inProximity(existingXY, touchedXY) {
    if ((existingXY[0] - touchedXY[0]).abs() < 20.0 &&
        (existingXY[1] - touchedXY[1]).abs() < 20.0) return true;
    return false;
  }

  bool _tooClose(existingXY, touchedXY) {
    if ((existingXY[0] - touchedXY[0]).abs() < 10.0 &&
        (existingXY[1] - touchedXY[1]).abs() < 10.0) return true;
    return false;
  }

  void switchEyes() {
    if (canvasCoordinates["rightEye"][0] < canvasCoordinates["leftEye"][0]) {
      var temp = canvasCoordinates["rightEye"];
      setState(() {
        this.canvasCoordinates["rightEye"] = canvasCoordinates["leftEye"];
        this.canvasCoordinates["leftEye"] = temp;
      });
    }
  }

  moveMouthLeftRight() {
    double deltaX = canvasCoordinates["mouth"][0] - mouthStartingPosition[0];
    double deltaY = canvasCoordinates["mouth"][1] - mouthStartingPosition[1];

    setState(() {
      canvasCoordinates["mouthLeft"][0] = mouthLeftStartingPosition[0] + deltaX;
      canvasCoordinates["mouthLeft"][1] = mouthLeftStartingPosition[1] + deltaY;

      canvasCoordinates["mouthRight"][0] =
          mouthRightStartingPosition[0] + deltaX;
      canvasCoordinates["mouthRight"][1] =
          mouthRightStartingPosition[1] + deltaY;
    });
  }

  double magImageYCompensator() {
    double posY = touchedXY[1] / canvasLength * imageSizeDifference;
    posY -= imageSizeDifference - magOffset;
    // Compensation logic, bumps magnified image below finger
    if (touchedXY[1] < magOffset) posY -= 200;
    return posY;
  }

  void _submitPicture() async {
    widget.newPicture.uploadPictureAndSaveToServer();
    pictures.add(widget.newPicture);
    cards.setCurrentPicture(widget.newPicture);
    await imageController.createDog(widget.newPicture);
  }

  void _submitEditedPicture() {
    RestAPI.updateImage(widget.newPicture);
    imageController.setFace();
    imageController.setMouthColor();
  }

  Future<void> handleSubmitButton() async {
    if (widget.editing || (widget.isNamed & widget.coordinatesSet)) {
      saveCanvasToPictureCoordinates();
      widget.editing ? _submitEditedPicture() : _submitPicture();
      Navigator.popUntil(
        context,
        ModalRoute.withName("main-screen"),
      );
    } else {
      return null;
    }
  }

  bool get _isEditing {
    return widget.editing || (widget.isNamed && widget.coordinatesSet);
  }

  void handleNameChange(name) {
    setState(() {
      widget.newPicture.setName(name);
      widget.isNamed = true;
      _instructionalText = _getInstructionalText();
      print("Handling name change");
    });
    FocusScope.of(context).unfocus();
    SystemChrome.restoreSystemUIOverlays();
  }

  Function _backCallback() {
    if (!widget.editing) widget.newPicture.delete();
    Navigator.popAndPushNamed(context, PhotoLibraryScreen.routeName);
  }

  _getImageData() {
    _isFirstBuild = false;
    canvasLength ??= MediaQuery.of(context).size.width;
    middle ??= canvasLength / 2;
    imageSizeDifference = magImageSize - canvasLength;
    print("imageSizeDifference: $imageSizeDifference");
    var bytes = File(widget.newPicture.filePath).readAsBytesSync();
    print("bytes count: ${bytes.length}");
    imageData = IMG.decodeImage(bytes);
    imageDataBytes =
        IMG.encodePng(IMG.copyResize(imageData, width: magImageSize));
  }

  void correctMouthSide(mouthSide) {
    if (mouthSide == "mouthLeft")
      canvasCoordinates[mouthSide] = mouthLeftStartingPosition;
    else if (mouthSide == "mouthRight")
      canvasCoordinates[mouthSide] = mouthRightStartingPosition;
  }

  bool mouthSidesTooClose(pointName) {
    return ((pointName == "mouthRight" &&
            _tooClose(canvasCoordinates["mouth"], touchedXY)) ||
        (pointName == "mouthLeft" &&
            _tooClose(canvasCoordinates["mouth"], touchedXY)));
  }

  String get grabPointName {
    if (grabPoint.isEmpty) return "";
    return grabPoint.keys.first;
  }

  Offset _getOffset(String pointName) {
    final xY = getCoordinatesForCanvas()[pointName];
    return Offset(xY[0], xY[1]);
  }

  double _getDistance(Offset one, Offset two) {
    return (one - two).distance;
  }

  bool _firstIsClosest(String pointName1, String pointName2, List comparandXY) {
    Offset first = _getOffset(pointName1);
    Offset second = _getOffset(pointName2);
    Offset comparand = Offset(comparandXY[0], comparandXY[1]);
    return _getDistance(first, comparand) < _getDistance(second, comparand);
  }

  String _getClosestPoint(touchedXY) {
    String closestPoint;
    getCoordinatesForCanvas().forEach((pointName, existingXY) {
      if (!_inProximity(existingXY, touchedXY))
        return;
      else if (closestPoint == null)
        closestPoint = pointName;
      else if (_firstIsClosest(pointName, closestPoint, touchedXY))
        closestPoint = pointName;
    });
    return closestPoint;
  }

  @override
  Widget build(BuildContext context) {
    print("building set picture coordinates screen");
    pictures = Provider.of<Pictures>(context, listen: false);
    imageController = Provider.of<ImageController>(context, listen: false);
    card = Provider.of<KaraokeCards>(context, listen: false).current;
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);

    SystemChrome.restoreSystemUIOverlays();
    if (_isFirstBuild) {
      _instructionalText = _getInstructionalText();
      _getImageData();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: CustomAppBar(
        nameInput: PhotoNameInput(widget.newPicture, handleNameChange),
      ),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            GestureDetector(
              // SETTING COORDINATES
              onPanStart: (details) async {
                touchedXY = [
                  details.localPosition.dx,
                  details.localPosition.dy
                ];
                String pointName = _getClosestPoint(touchedXY);
                if (pointName == null) return;
                setState(() {
                  touchedXY = touchedXY;
                  grabbing = true;
                  grabPoint[pointName] = canvasCoordinates[pointName];
                  widget.coordinatesSet = true;
                  print("IN PROXIMITY!!");
                  if (pointName == "mouth")
                    mouthStartingPosition = grabPoint[pointName];
                  mouthLeftStartingPosition =
                      List.from(canvasCoordinates["mouthLeft"]);
                  mouthRightStartingPosition =
                      List.from(canvasCoordinates["mouthRight"]);
                });
              },
              onPanUpdate: (details) {
                if (!grabbing) return;
                setState(() {
                  touchedXY = [
                    details.localPosition.dx,
                    details.localPosition.dy
                  ];
                  // Coordinate points are modified here
                  canvasCoordinates[grabPointName] = touchedXY;
                  // Move mouthLeft and mouthRight with mouth
                  if (grabPointName == "mouth") moveMouthLeftRight();
                });
              },
              onPanEnd: (details) async {
                if (!grabbing) return;
                String pointName = grabPoint.keys.first;
                if (mouthSidesTooClose(pointName)) correctMouthSide(pointName);
                switchEyes();
                setState(() {
                  grabbing = false;
                  grabPoint = {};
                });
              },
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      // possible issue
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Image.file(File(widget.newPicture.filePath),
                            width: 512, height: 512),
                      ),
                    ),
                    // Points and lines
                    Visibility(
                      visible: widget.isNamed ? true : false,
                      child: CustomPaint(
                        painter: CoordinatesPainter(getCoordinatesForCanvas(),
                            magnifiedImage, touchedXY),
                        child: Container(),
                      ),
                    ),
                    // Magnifying glass
                    Visibility(
                      visible: grabbing,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0 -
                                (touchedXY[0] /
                                    canvasLength *
                                    imageSizeDifference),
                            bottom: magImageYCompensator(),
                            child: ClipOval(
                                clipper:
                                    MagnifiedImage(touchedXY[0], touchedXY[1]),
                                child: Image.memory(imageDataBytes)),
                          ),
                          CustomPaint(
                            painter: MagnifyingTargetPainter(
                              touchedXY,
                              grabPoint.keys,
                              mouthSidesTooClose(grabPointName),
                            ),
                            child: Container(),
                          ),
                        ],
                      ),
                    ),
                    // CustomPaint(
                    //   painter: PointLabelsPainter(canvasCoordinates),
                    //   child: Container(),
                    // ),
                  ],
                ),
              ),
            ),
            CardProgressBar(),
            Padding(
              padding: EdgeInsets.only(top: 15),
            ),
            InterfaceTitleNav(
              _instructionalText,
              titleSize: 22,
              backCallback: _backCallback,
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: resetCanvasCoordinates,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 2.0,
                  fillColor:
                      _isEditing ? Theme.of(context).errorColor : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                RawMaterialButton(
                  onPressed: handleSubmitButton,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 2.0,
                  fillColor:
                      _isEditing ? Theme.of(context).primaryColor : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MagnifiedImage extends CustomClipper<Rect> {
  final canvasX;
  final canvasY;

  MagnifiedImage(this.canvasX, this.canvasY);

  double get getPostY {
    double pos;
    pos = canvasY + (canvasY / canvasLength * imageSizeDifference);
    return pos;
  }

  @override
  Rect getClip(Size size) {
    double posX = canvasX + (canvasX / canvasLength * imageSizeDifference);
    Rect rect = Rect.fromCenter(
        center: Offset(
          posX,
          getPostY,
        ),
        width: magOffset * 1.8,
        height: magOffset * 1.8);
    return rect;
  }

  @override
  bool shouldReclip(oldClipper) => true;
}

// // must be separate for stacking purposes
// class PointLabelsPainter extends CustomPainter {
//   final coordinates;
//   PointLabelsPainter(this.coordinates);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4.0
//       ..color = Colors.blue;

//     Offset adjustOffset(List coordinates, Size tpSize) {
//       return Offset(coordinates[0] - (tpSize.width / 2), coordinates[1] - 40);
//     }

//     void drawPointLabels() {
//       coordinates.forEach((name, location) {
//         var tp = TextPainter(
//             // textScaleFactor: 1.0,
//             text: TextSpan(
//               text: displayNames[name],
//               style: TextStyle(fontFamily: 'lato', fontSize: 15),
//             ),
//             textAlign: TextAlign.center,
//             textDirection: TextDirection.ltr);
//         tp.layout();
//         tp.paint(canvas, adjustOffset(location, tp.size));
//       });
//     }

//     drawPointLabels();
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDeligate) => true;
// }

class MagnifyingTargetPainter extends CustomPainter {
  final touchedXY;
  final grabPoint;
  final bool tooCloseWarning;

  MagnifyingTargetPainter(
    this.touchedXY,
    this.grabPoint,
    this.tooCloseWarning,
  );

  Offset adjustOffset(Offset offset, Size tpSize, {yOffset = 0}) {
    return Offset(offset.dx - (tpSize.width / 2), offset.dy - 40 + yOffset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    void drawMagnifier() {
      double posY = touchedXY[1];
      // Compensation logic, bumps magnified image marker below finger
      posY = posY < magOffset ? posY + 200 : posY;
      final offset = Offset(
        touchedXY[0],
        posY - magOffset,
      );
      canvas.drawCircle(
        offset,
        4.0,
        paint,
      );

      final tp = TextPainter(
          // textScaleFactor: 1.0,
          text: TextSpan(
            text: displayNames[grabPoint.first],
            style: TextStyle(
                fontFamily: 'lato',
                fontSize: 25,
                color: Colors.blue,
                fontWeight: FontWeight.bold),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, adjustOffset(offset, tp.size));

      if (tooCloseWarning) {
        final tooCloseTp = TextPainter(
            text: TextSpan(
              text: "TOO CLOSE\n TO MOUTH\nCENTER",
              style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 20,
                  color: Colors.redAccent[400],
                  fontWeight: FontWeight.bold),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
        tooCloseTp.layout();
        tooCloseTp.paint(
            canvas, adjustOffset(offset, tooCloseTp.size, yOffset: 25));
      }
    }

    if (grabPoint.isEmpty) return;
    drawMagnifier();
  }

  @override
  bool shouldRepaint(CustomPainter oldDeligate) => true;
}

class CoordinatesPainter extends CustomPainter {
  final coordinates;
  final ui.Image magnifiedImage;
  final touchedXY;

  CoordinatesPainter(this.coordinates, this.magnifiedImage, this.touchedXY)
      : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    void drawBothEyes() {
      canvas.drawCircle(
        Offset(coordinates["rightEye"][0], coordinates["rightEye"][1]),
        15.0,
        paint,
      );

      canvas.drawCircle(
        Offset(coordinates["leftEye"][0], coordinates["leftEye"][1]),
        15.0,
        paint,
      );

      canvas.drawCircle(
        Offset(coordinates["rightEye"][0], coordinates["rightEye"][1]),
        1.0,
        paint,
      );

      canvas.drawCircle(
        Offset(
          coordinates["leftEye"][0],
          coordinates["leftEye"][1],
        ),
        1.0,
        paint,
      );
    }

    // MOUTH
    void drawMouth() {
      canvas.drawCircle(
          Offset(coordinates["mouth"][0], coordinates["mouth"][1]), 3.0, paint);

      canvas.drawCircle(
          Offset(coordinates["mouthLeft"][0], coordinates["mouthLeft"][1]),
          2.0,
          paint);

      canvas.drawCircle(
          Offset(coordinates["mouthRight"][0], coordinates["mouthRight"][1]),
          2.0,
          paint);

      // connect mouth

      canvas.drawLine(
          Offset(coordinates["mouth"][0], coordinates["mouth"][1]),
          Offset(coordinates["mouthLeft"][0], coordinates["mouthLeft"][1]),
          paint);
      canvas.drawLine(
          Offset(coordinates["mouth"][0], coordinates["mouth"][1]),
          Offset(coordinates["mouthRight"][0], coordinates["mouthRight"][1]),
          paint);
    }

    // HEAD
    void drawHeadPoints() {
      canvas.drawCircle(
        Offset(coordinates["headTop"][0], coordinates["headTop"][1]),
        7.0,
        paint,
      );

      canvas.drawCircle(
        Offset(coordinates["headRight"][0], coordinates["headRight"][1]),
        7.0,
        paint,
      );

      canvas.drawCircle(
        Offset(coordinates["headBottom"][0], coordinates["headBottom"][1]),
        7.0,
        paint,
      );

      canvas.drawCircle(
        Offset(coordinates["headLeft"][0], coordinates["headLeft"][1]),
        7.0,
        paint,
      );

      // Draw oval around head
      Path path = Path();
      path.addArc(
        Rect.fromLTRB(coordinates["headLeft"][0], coordinates["headTop"][1],
            coordinates["headRight"][0], coordinates["headBottom"][1]),
        pi,
        2 * pi,
      );
      canvas.drawPath(path, paint);
    }

    drawBothEyes();
    drawMouth();
    drawHeadPoints();
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
