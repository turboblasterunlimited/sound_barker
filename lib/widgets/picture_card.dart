import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';

class PictureCard extends StatefulWidget {
  final int index;
  final Picture picture;
  final Pictures pictures;
  PictureCard(this.index, this.picture, this.pictures, {Key key})
      : super(key: key);

  @override
  _PictureCardState createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard>
    with TickerProviderStateMixin {
  ImageController imageController;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // If was just created, animate. Otherwise, don't.
    if (widget.picture.creationAnimation) {
      animationController.forward();
    } else {
      animationController.forward(from: 1.0);
    }
  }

  @override
  void dispose() {
    widget.picture.creationAnimation = false;
    animationController.dispose();
    super.dispose();
  }

  String imageActions(String action) {
    if (action == "DELETE") {
      animationController.reverse();
      widget.pictures.remove(widget.picture);
      imageController.loadImage(widget.pictures.all.first);
    } else if (action == "SET MOUTH") {
    } else if (action == "RENAME") {}
  }

  pictureCard(animation) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  imageController.loadImage(widget.picture);
                  widget.pictures.mountedPicture = widget.picture;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(widget.picture.filePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: -25,
                top: -5,
                child: Stack(
                  children: <Widget>[
                    PopupMenuButton(
                      onSelected: imageActions,
                      child: RawMaterialButton(
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.black38,
                          size: 20,
                        ),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.white,
                      ),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: "RENAME",
                            child: Text("Rename"),
                          ),
                          PopupMenuItem<String>(
                            value: "SET MOUTH",
                            child: Text("Set mouth"),
                          ),
                          PopupMenuItem<String>(
                            value: "DELETE",
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context);
    Animation animation = Tween(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(parent: animationController, curve: Curves.ease));

    return AnimatedBuilder(
      key: widget.key,
      animation: animation,
      child: pictureCard(animation),
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: child,
        );
      },
    );
  }
}
