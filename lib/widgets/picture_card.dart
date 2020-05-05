import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';
import '../screens/confirm_picture_screen.dart';

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
  TabListScrollController tabListScrollController;

  @override
  void initState() {
    super.initState();
    tabListScrollController =
        Provider.of<TabListScrollController>(context, listen: false);
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
      widget.pictures.remove(widget.picture);
      imageController.createDog(widget.pictures.all.first);
    } else if (action == "SET FACE") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmPictureScreen(widget.picture, isNamed: true),
        ),
      );
    } else if (action == "RENAME") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmPictureScreen(widget.picture, coordinatesSet: true),
        ),
      );
    }
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
                  imageController.createDog(widget.picture);
                  widget.pictures.mountedPicture = widget.picture;
                  handleTabScroll();
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
            ],
          ),
        ),
      ),
    );
  }

  void handleTabScroll() {
    if (tabListScrollController.tabExtent == 0.8) {
      var position = tabListScrollController.scrollController.position.pixels;
      position += 250;
      DraggableScrollableActuator.reset(context);
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        tabListScrollController.scrollController.jumpTo(position);
      });
      tabListScrollController.updateTabExtent(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
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
