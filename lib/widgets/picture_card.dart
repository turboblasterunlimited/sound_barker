import 'dart:math';

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

  pictureCard(animation) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print("Clicked on image...");
                  imageController.loadImage(widget.picture);
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
                child: RawMaterialButton(
                  onPressed: () async {
                    await animationController.reverse();
                    widget.pictures.remove(widget.picture);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.black38,
                    size: 20,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.red,
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
    Animation animation =
        Tween(begin: 0.0, end: 1.0).animate(animationController);

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
