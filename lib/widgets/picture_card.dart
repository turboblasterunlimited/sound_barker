import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';
import '../screens/set_picture_coordinates_screen.dart';

class PictureCard extends StatefulWidget {
  final Picture picture;
  final Pictures pictures;
  PictureCard(this.picture, this.pictures, {Key key})
      : super(key: key);

  @override
  _PictureCardState createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard>
    with TickerProviderStateMixin {
  ImageController imageController;
  AnimationController animationController;
  KaraokeCards cards;
  CurrentActivity currentActivity;

  @override
  void initState() {
    super.initState();
    imageController = Provider.of<ImageController>(context, listen: false);

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // If was just created, animate in. Otherwise, don't.
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

  void imageActions(String action) {
    if (action == "DELETE") {
      animationController.reverse();
      final newMounted = widget.pictures.remove(widget.picture);
      newMounted ?? imageController.createDog(newMounted);
    } else if (action == "SET FACE") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(widget.picture, editing: true),
        ),
      );
    } else if (action == "RENAME") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(widget.picture, editing: true),
        ),
      );
    }
  }

  void handleTap() {
    print("dog name: ${widget.picture.name}");
    cards.setCurrentPicture(widget.picture);
    currentActivity.setCardCreationStep(CardCreationSteps.song);
    imageController.createDog(widget.picture);
    Navigator.popUntil(context, ModalRoute.withName("main-screen"));
  }

  Widget pictureCard(animation) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: handleTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(widget.picture.filePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Visibility(
                visible: !widget.picture.isStock,
                child: Positioned(
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
                              value: "SET FACE",
                              child: Text("Set face"),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    Animation animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));

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
