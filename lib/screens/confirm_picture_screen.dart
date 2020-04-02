import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';
import '../providers/image_controller.dart';

class ConfirmPictureScreen extends StatefulWidget {
  Picture newPicture;
  bool isNamed;
  bool mouthAreaSet;
  bool editing;
  String title;
  String imageName;

  ConfirmPictureScreen(Picture newPicture, {isNamed, mouthAreaSet}) {
    this.newPicture = newPicture;
    this.editing = isNamed ?? mouthAreaSet ?? false;
    this.isNamed = isNamed ?? false;
    this.mouthAreaSet = mouthAreaSet ?? false;
    if (this.editing == true) {
      this.title =
          this.isNamed == false ? "Rename your picture" : "Highlight the mouth";
    } else {
      this.title = "Name your picture";
    }
    this.imageName = this.newPicture.name ?? "";
  }

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
    print("MOUTH AREA SET?? ${widget.mouthAreaSet}");

    String dartToJsCoordinates() {
      double length = MediaQuery.of(context).size.width;
      double left = widget.coordinates["left"] / length;
      double top = 1 - (widget.coordinates["top"] / length);
      double right =
          (widget.coordinates["left"] + widget.coordinates["width"]) / length;
      double bottom = 1 -
          (widget.coordinates["top"] + widget.coordinates["height"]) / length;
      return "[$left, $top], [$right, $bottom]";
    }

    void _submitPicture() {
      // print("New picture name: ${widget.newPicture.name}");
      widget.newPicture.mouthCoordinates = dartToJsCoordinates();
      widget.newPicture.uploadPictureAndSaveToServer();
      pictures.add(widget.newPicture);
      pictures.mountedPicture = widget.newPicture;
      imageController.loadImage(widget.newPicture);
      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
    }

    void _submitEditedPicture() {
      // print("Edited picture name: ${widget.newPicture.name}");
      // print(
      //     "Edited picture coordinates: ${widget.newPicture.mouthCoordinates}");
      // print("widget.mouthAreaSet?????: ${widget.mouthAreaSet}");

      // Name was being edited.
      if (widget.isNamed) {
        widget.newPicture.mouthCoordinates = dartToJsCoordinates();
      }
      widget.newPicture.updateImageOnServer(widget.newPicture);
      pictures.mountedPicture = widget.newPicture;
      imageController.loadImage(widget.newPicture);

      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
    }

    // bool invalid() {
    //   if (widget.newPicture.name == null) return true;
    //   if (widget.coordinates["width"] == 0.0) return true;
    //   return false;
    // }

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      // extendBodyBehindAppBar: true,
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
          backgroundColor: Theme.of(context).accentColor,
          // elevation: 0,
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
                          setState(() {
                            widget.newPicture.name = widget.imageName;
                            if (widget.editing == false) {
                              widget.title = "Highlight the mouth";
                              widget.isNamed = true;
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
                      onPanStart: (details) {
                        // print("Start X: ${details.localPosition.dx}");
                        // print("Start Y: ${details.localPosition.dy}");

                        setState(() {
                          widget.coordinates["left"] = details.localPosition.dx;
                          widget.coordinates["top"] = details.localPosition.dy;
                        });
                      },
                      onPanUpdate: (details) {
                        // print("Update X: ${details.localPosition.dx}");
                        // print("Update Y: ${details.localPosition.dy}");
                        setState(() {
                          widget.coordinates["width"] =
                              details.localPosition.dx -
                                  widget.coordinates["left"];
                          widget.coordinates["height"] =
                              details.localPosition.dy -
                                  widget.coordinates["top"];
                        });
                      },
                      onPanEnd: (details) async {
                        widget.title = "Looks good!";
                        setState(() => widget.mouthAreaSet = true);
                      },
                      child: CustomPaint(
                        painter: CoordinatesMaker(widget.coordinates),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.mouthAreaSet,
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

class CoordinatesMaker extends CustomPainter {
  final coordinates;
  CoordinatesMaker(this.coordinates) : super();
  @override
  void paint(Canvas canvas, Size size) {
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
