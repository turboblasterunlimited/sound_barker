import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';
import '../providers/image_controller.dart';

class ConfirmPictureScreen extends StatefulWidget {
  final Picture newPicture;
  ConfirmPictureScreen(this.newPicture);
  final Map coordinates = {
    "left": 0.0,
    "top": 0.0,
    "width": 0.0,
    "height": 0.0,
  };

  @override
  _ConfirmPictureScreenState createState() => _ConfirmPictureScreenState();
}

class _ConfirmPictureScreenState extends State<ConfirmPictureScreen> {
  @override
  Widget build(BuildContext context) {
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    ImageController imageController = Provider.of<ImageController>(context);
    String _pictureName = "";

    void _submitPicture(context) {
      widget.newPicture.name = _pictureName;
      widget.newPicture.uploadPictureAndSaveToServer();
      pictures.add(widget.newPicture);
      pictures.mountedPicture = widget.newPicture;
      imageController.loadImage(widget.newPicture);

      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
    }

    var outlineColor = Colors.black;

    Widget paintOnPicture() {
      return GestureDetector(
        onPanStart: (details) {
          // print("Start: ${details.globalPosition}");
          setState(() {
            widget.coordinates["left"] = details.globalPosition.dx;
            widget.coordinates["top"] = details.globalPosition.dy;
            // print("Start! coordinates: $_coordinates");
          });
        },
        onPanUpdate: (details) {
          // print("Update dx: ${details.globalPosition.dx}");
          // print("Update dy: ${details.globalPosition.dy}");

          setState(() {
            widget.coordinates["width"] =
                details.globalPosition.dx - widget.coordinates["left"];
            widget.coordinates["height"] =
                details.globalPosition.dy - widget.coordinates["top"];
            // print(widget.coordinates.hashCode);
          });
          print("coordinates: $widget.coordinates");
        },
        onPanEnd: (details) {
          print("Done painting!");
        },
        child: CustomPaint(
          painter: CoordinatesMaker(widget.coordinates),
          child: Container(
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(28.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Song Barker',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                shadows: [
                  Shadow(
                      // bottomLeft
                      offset: Offset(-1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // bottomRight
                      offset: Offset(1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // topRight
                      offset: Offset(1.5, 1.5),
                      color: outlineColor),
                  Shadow(
                      // topLeft
                      offset: Offset(-1.5, 1.5),
                      color: outlineColor),
                ],
                color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Image.file(
                  File(widget.newPicture.filePath),
                ),
                paintOnPicture(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    onChanged: (value) {
                      _pictureName = value;
                    },
                    onFieldSubmitted: (value) {
                      if (value.isEmpty) return;
                      _submitPicture(context);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Give it a name',
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {
                            _submitPicture(context);
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CoordinatesMaker extends CustomPainter {
  final coordinates;
  CoordinatesMaker(this.coordinates) : super();
  @override
  void paint(Canvas canvas, Size size) {
    print(coordinates.hashCode);
    print("coordinates from painter: $coordinates");
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.blue;

    canvas.drawRect(
        Rect.fromLTWH(coordinates["left"], coordinates["top"],
            coordinates["width"], coordinates["height"]),
        paint);
  }

  bool shouldRepaint(CustomPainter oldDeligate) => true;
}
