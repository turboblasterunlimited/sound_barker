import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';

import '../providers/pictures.dart';
import '../providers/image_controller.dart';
import '../services/rest_api.dart';

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
          this.isNamed == false ? "Rename your picture" : "Mark the eyes";
    } else {
      this.title = "Name your picture";
    }
    this.imageName = this.newPicture.name ?? "";
  }

  @override
  _ConfirmPictureScreenState createState() => _ConfirmPictureScreenState();
}

class _ConfirmPictureScreenState extends State<ConfirmPictureScreen> {
  double screenLength;
  Map<String, List<double>> canvasCoordinates = {};
  double middle;

  Map<String, List<double>> getCanvasCoordinates() {
    if (canvasCoordinates.length != 0) return canvasCoordinates;

    final puppetCoordinates = json.decode(widget.newPicture.coordinates);

    if (puppetCoordinates["mouth"] == null) {
      puppetCoordinates["mouth"] = [0.0, 0.0];
    }

    if (puppetCoordinates["headTop"] == null) {
      puppetCoordinates["headTop"] = [0.0, .3];
    }

    if (puppetCoordinates["headRight"] == null) {
      puppetCoordinates["headRight"] = [0.3, .0];
    }

    if (puppetCoordinates["headBottom"] == null) {
      puppetCoordinates["headBottom"] = [0.0, -.3];
    }

    if (puppetCoordinates["headLeft"] == null) {
      puppetCoordinates["headLeft"] = [-0.3, .0];
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

    puppetCoordinates.forEach((key, xy) {
      canvasCoordinates[key] = [
        _puppetXtoCanvasX(xy[0]),
        _puppetYtoCanvasY(xy[1])
      ];
    });

    print("Canvas Coordinates: $canvasCoordinates");
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
    screenLength ??= MediaQuery.of(context).size.width;
    middle ??= screenLength / 2;
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
        ModalRoute.withName(Navigator.defaultRouteName),
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
        ModalRoute.withName(Navigator.defaultRouteName),
      );
    }

    bool _inProximity(existingXY, touchedXY) {
      if ((existingXY[0] - touchedXY[0]).abs() < 10.0 &&
          (existingXY[0] - touchedXY[0]).abs() < 10.0) return true;
      return false;
    }

    void magnifyPixels(x, y) {
      // getPixel(x, y);

    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          leading: RawMaterialButton(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22,
            ),
            // shape: CircleBorder(),
            // elevation: 2.0,
            // fillColor: Theme.of(context).accentColor,

            // padding: const EdgeInsets.all(15.0),
            onPressed: () {
              // BACK ARROW
              setState(() {
                if (widget.editing) {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName(Navigator.defaultRouteName),
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
                      onPanStart: (details) {
                        // print("Start X: ${details.localPosition.dx}");
                        // print("Start Y: ${details.localPosition.dy}");
                        List touchedXY = [
                          details.localPosition.dx,
                          details.localPosition.dy
                        ];
                        getCanvasCoordinates().forEach((pointName, existingXY) {
                          if (!_inProximity(existingXY, touchedXY)) return;
                          setState(() {
                            grabbing = true;
                            grabPoint[pointName] = existingXY;
                            widget.coordinatesSet = true;
                            print("IN PROXIMITY!!");
                          });
                        });
                      },
                      onPanUpdate: (details) {
                        magnifyPixels(
                            details.localPosition.dx, details.localPosition.dy);
                        if (!grabbing) return;

                        setState(() {
                          canvasCoordinates[grabPoint.keys.first.toString()] = [
                            details.localPosition.dx,
                            details.localPosition.dy
                          ];
                        });
                      },
                      onPanEnd: (details) async {
                        if (!grabbing) return;
                        setState(() {
                          grabbing = false;
                          grabPoint = {};
                        });
                      },
                      child: CustomPaint(
                        painter: CoordinatesPainter(getCanvasCoordinates()),
                        child: Container(),
                      ),
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

class CoordinatesPainter extends CustomPainter {
  final coordinates;
  CoordinatesPainter(this.coordinates) : super();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..color = Colors.blue;

    void drawBothEyes() {
      print("DRAWING EYES");
      print("Coordinates: $coordinates");
      canvas.drawCircle(
          Offset(coordinates["rightEye"][0], coordinates["rightEye"][1]),
          15.0,
          paint);

      canvas.drawCircle(
          Offset(coordinates["leftEye"][0], coordinates["leftEye"][1]),
          15.0,
          paint);
    }

    void drawMouth() {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center:
                      Offset(coordinates["mouth"][0], coordinates["mouth"][1]),
                  height: 20.0,
                  width: 70.0),
              Radius.circular(10.0)),
          paint);
    }

    void drawHeadPoints() {
      canvas.drawCircle(
          Offset(coordinates["headTop"][0], coordinates["headTop"][1]),
          7.0,
          paint);

      canvas.drawCircle(
          Offset(coordinates["headRight"][0], coordinates["headRight"][1]),
          7.0,
          paint);

      canvas.drawCircle(
          Offset(coordinates["headBottom"][0], coordinates["headBottom"][1]),
          7.0,
          paint);

      canvas.drawCircle(
          Offset(coordinates["headLeft"][0], coordinates["headLeft"][1]),
          7.0,
          paint);

      // Draw oval around head
      Path path = Path();
      path.addArc(
          Rect.fromLTRB(coordinates["headLeft"][0], coordinates["headTop"][1],
              coordinates["headRight"][0], coordinates["headBottom"][1]),
          pi,
          2 * pi);
      canvas.drawPath(path, paint);
    }

    drawBothEyes();
    drawMouth();
    drawHeadPoints();
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
