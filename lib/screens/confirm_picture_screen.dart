import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as IMG;
import 'package:flutter/painting.dart';
import 'package:song_barker/screens/main_screen.dart';
import 'dart:ui' as ui;

import '../providers/pictures.dart';
import '../providers/image_controller.dart';
import '../services/rest_api.dart';

double canvasLength;
double imageSizeDifference;

double magOffset = 80;
int magImageSize = 550;

class ConfirmPictureScreen extends StatefulWidget {
  Picture newPicture;
  bool isNamed;
  bool coordinatesSet;
  bool editing;
  String title;
  String imageName;

  ConfirmPictureScreen(Picture newPicture, {isNamed, coordinatesSet}) {
    this.newPicture = newPicture;
    this.editing = isNamed ?? coordinatesSet ?? false;
    this.isNamed = isNamed ?? false;
    this.coordinatesSet = coordinatesSet ?? false;
    if (this.editing == true) {
      this.title =
          this.isNamed == false ? "Rename your picture" : "Set the face";
    } else {
      this.title = "Name it!";
    }
    this.imageName = this.newPicture.name ?? "";
  }

  @override
  _ConfirmPictureScreenState createState() => _ConfirmPictureScreenState();
}

class _ConfirmPictureScreenState extends State<ConfirmPictureScreen> {
  Map<String, List<double>> canvasCoordinates = {};
  double middle;
  IMG.Image imageData;
  Uint8List imageDataBytes;
  // Canvas pixels
  List<double> touchedXY = [0.0, 0.0];
  ui.Image magnifiedImage;
  List<double> mouthStartingPosition = [0.0, 0.0];
  List<double> mouthLeftStartingPosition = [0.0, 0.0];
  List<double> mouthRightStartingPosition = [0.0, 0.0];

  void didChangeDependencies() {
    canvasLength ??= MediaQuery.of(context).size.width;
    middle ??= canvasLength / 2;
    super.didChangeDependencies();
    imageData =
        IMG.decodeImage(File(widget.newPicture.filePath).readAsBytesSync());
    imageDataBytes =
        IMG.encodePng(IMG.copyResize(imageData, width: magImageSize));
    imageSizeDifference = magImageSize - canvasLength;
    print("imageSizeDifference: $imageSizeDifference");
  }

  Map setMissingCoordinatesToDefault(puppetCoordinates) {
    if (puppetCoordinates["leftEye"] == null)
      puppetCoordinates["leftEye"] = [-0.2, 0.2];

    if (puppetCoordinates["rightEye"] == null)
      puppetCoordinates["rightEye"] = [0.2, 0.2];

    if (puppetCoordinates["mouth"] == null)
      puppetCoordinates["mouth"] = [0.0, 0.0];

    if (puppetCoordinates["mouthLeft"] == null)
      puppetCoordinates["mouthLeft"] = [-0.1, 0.0];

    if (puppetCoordinates["mouthRight"] == null)
      puppetCoordinates["mouthRight"] = [0.1, 0.0];

    if (puppetCoordinates["headTop"] == null)
      puppetCoordinates["headTop"] = [0.0, .4];

    if (puppetCoordinates["headRight"] == null)
      puppetCoordinates["headRight"] = [0.3, .0];

    if (puppetCoordinates["headBottom"] == null)
      puppetCoordinates["headBottom"] = [0.0, -.4];

    if (puppetCoordinates["headLeft"] == null)
      puppetCoordinates["headLeft"] = [-0.3, .0];

    return puppetCoordinates;
  }

  Map<String, List<double>> getCoordinatesForCanvas() {
    if (canvasCoordinates.length != 0) return canvasCoordinates;

    Map puppetCoordinates = json.decode(widget.newPicture.coordinates);

    puppetCoordinates = setMissingCoordinatesToDefault(puppetCoordinates);

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

    puppetCoordinates.forEach((key, xy) {
      canvasCoordinates[key] = [
        _puppetXtoCanvasX(xy[0]),
        _puppetYtoCanvasY(xy[1])
      ];
    });

    return canvasCoordinates;
  }

  canvasToPuppetCoordinates() {
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

    Map<String, List<double>> puppetCoordinates = {};
    canvasCoordinates.forEach((String key, List xy) {
      puppetCoordinates[key] = [
        _canvasXToPuppetX(xy[0]),
        _canvasYToPuppetY(xy[1])
      ];
    });

    return json.encode(puppetCoordinates);
  }

  bool grabbing = false;
  Map<String, List<double>> grabPoint = {};

  @override
  Widget build(BuildContext context) {
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    ImageController imageController = Provider.of<ImageController>(context);

    void _submitPicture() {
      widget.newPicture.coordinates = canvasToPuppetCoordinates();
      widget.newPicture.uploadPictureAndSaveToServer();
      pictures.add(widget.newPicture);
      pictures.mountedPicture = widget.newPicture;
      imageController.createDog(widget.newPicture);
      Navigator.popUntil(
        context,
        ModalRoute.withName(MainScreen.routeName),
      );
    }

    void _submitEditedPicture() {
      if (widget.isNamed) {
        widget.newPicture.coordinates = canvasToPuppetCoordinates();
      }
      RestAPI.updateImageOnServer(widget.newPicture);
      pictures.mountedPicture = widget.newPicture;
      imageController.createDog(widget.newPicture);

      Navigator.popUntil(
        context,
        ModalRoute.withName(MainScreen.routeName),
      );
    }

    bool _inProximity(existingXY, touchedXY) {
      if ((existingXY[0] - touchedXY[0]).abs() < 10.0 &&
          (existingXY[1] - touchedXY[1]).abs() < 10.0) return true;
      return false;
    }

    double magImageYCompensator() {
      double posY = touchedXY[1] / canvasLength * imageSizeDifference;
      posY -= imageSizeDifference - magOffset;
      // Need compensation logic here.
      return posY;
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
        canvasCoordinates["mouthLeft"][0] =
            mouthLeftStartingPosition[0] + deltaX;
        canvasCoordinates["mouthLeft"][1] =
            mouthLeftStartingPosition[1] + deltaY;

        canvasCoordinates["mouthRight"][0] =
            mouthRightStartingPosition[0] + deltaX;
        canvasCoordinates["mouthRight"][1] =
            mouthRightStartingPosition[1] + deltaY;
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          centerTitle: true,
          leading: RawMaterialButton(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              // BACK ARROW
              setState(() {
                if (widget.editing) {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName(MainScreen.routeName),
                  );
                } else if (!widget.isNamed) {
                  // if on first screen
                  Navigator.of(context).pop();
                } else {
                  // if on second screen
                  widget.isNamed = false;
                  widget.title = 'Name your picture';
                }
              });
            },
          ),
          title: Text(widget.title),
          iconTheme: IconThemeData(color: Colors.white, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Stack(
                children: <Widget>[
                  Image.file(
                    File(widget.newPicture.filePath),
                  ),
                  Visibility(
                    visible: !widget.isNamed,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                        autofocus: true,
                        initialValue: widget.imageName,
                        onChanged: (newName) {
                          widget.imageName = newName;
                        },
                        onFieldSubmitted: (_) {
                          // NAMING
                          setState(() {
                            widget.newPicture.name = widget.imageName;
                            if (widget.editing == false) {
                              widget.title = "Align face points";
                              widget.isNamed = true;
                              widget.coordinatesSet = true;
                            } else if (widget.editing == true) {
                              _submitEditedPicture();
                            } else {
                              widget.title = "Looks good!";
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isNamed,
                    child: GestureDetector(
                      // SETTING COORDINATES
                      onPanStart: (details) async {
                        touchedXY = [
                          details.localPosition.dx,
                          details.localPosition.dy
                        ];
                        getCoordinatesForCanvas()
                            .forEach((pointName, existingXY) {
                          if (!_inProximity(existingXY, touchedXY)) return;
                          setState(() {
                            touchedXY = touchedXY;
                            grabbing = true;
                            grabPoint[pointName] = existingXY;
                            widget.coordinatesSet = true;
                            print("IN PROXIMITY!!");
                            if (pointName == "mouth")
                              mouthStartingPosition = existingXY;
                            mouthLeftStartingPosition =
                                List.from(canvasCoordinates["mouthLeft"]);
                            mouthRightStartingPosition =
                                List.from(canvasCoordinates["mouthRight"]);
                          });
                        });
                      },
                      onPanUpdate: (details) {
                        if (!grabbing) return;
                        String pointName = grabPoint.keys.first;

                        setState(() {
                          touchedXY = [
                            details.localPosition.dx,
                            details.localPosition.dy
                          ];
                          // The coordinate points are modified here
                          canvasCoordinates[pointName] = touchedXY;
                          // Move mouthLeft and mouthRight with mouth
                          if (pointName == "mouth") moveMouthLeftRight();
                        });
                      },
                      onPanEnd: (details) async {
                        if (!grabbing) return;
                        switchEyes();
                        setState(() {
                          grabbing = false;
                          grabPoint = {};
                        });
                      },
                      child: CustomPaint(
                        painter: CoordinatesPainter(getCoordinatesForCanvas(),
                            magnifiedImage, touchedXY, grabbing),
                        child: Container(),
                      ),
                    ),
                  ),
                  // Magnifying glass
                  Visibility(
                    visible: widget.isNamed && grabbing,
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
                              touchedXY, grabPoint.keys),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.coordinatesSet,
              child: SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: () {
                        if (widget.editing) {
                          _submitEditedPicture();
                        } else {
                          _submitPicture();
                        }
                      },
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.black38,
                        size: 40,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.green,
                      padding: const EdgeInsets.all(15.0),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.thumb_down,
                        color: Colors.black38,
                        size: 40,
                      ),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.red,
                      padding: const EdgeInsets.all(15.0),
                    ),
                  ],
                ),
              ),
            )
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
    // Compensation logic for static clipper at top of screen commented out until working.
    // if (canvasY < magOffset) {
    //   return (magOffset) + (canvasY / canvasLength * imageSizeDifference);
    // }
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

class MagnifyingTargetPainter extends CustomPainter {
  final touchedXY;
  final grabPoint;
  MagnifyingTargetPainter(this.touchedXY, this.grabPoint);



  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    double posY = touchedXY[1];
    // Compensation logic for static clipper marker at top of screen commented out until working.
    // posY = posY < magOffset
    //     ? magOffset
    //     : posY;

    canvas.drawCircle(
      Offset(
        touchedXY[0],
        posY - magOffset,
      ),
      4.0,
      paint,
    );

    if (grabPoint.length == 0) return;

    final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: grabPoint.first,
          style: TextStyle(fontFamily: 'lato'),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(
      canvas,
      Offset(
        touchedXY[0] - 40,
        posY - magOffset + 20,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDeligate) => true;
}

class CoordinatesPainter extends CustomPainter {
  final coordinates;
  final ui.Image magnifiedImage;
  final touchedXY;
  final grabbing;

  CoordinatesPainter(
      this.coordinates, this.magnifiedImage, this.touchedXY, this.grabbing)
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
