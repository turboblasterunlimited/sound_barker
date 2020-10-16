import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';
import '../screens/set_picture_coordinates_screen.dart';

class PictureCard extends StatefulWidget {
  final Picture picture;
  final Pictures pictures;
  List<Widget> displayList;
  PictureCard(this.picture, this.pictures, this.displayList, {Key key})
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
      widget.displayList.remove(this);
      widget.pictures.remove(widget.picture);
    }
  }

  void handleTap() {
    print("dog name: ${widget.picture.name}");
    cards.setCurrentPicture(widget.picture);
    currentActivity.setCardCreationStep(CardCreationSteps.song);
    imageController.createDog(widget.picture);
    Navigator.popUntil(context, ModalRoute.withName("main-screen"));
  }

  Widget _imageWidget() {
    return Image.file(
      File(widget.picture.filePath),
      fit: BoxFit.cover,
    );
  }

  Widget _getImage() {
    if (widget.picture.hasFile) {
      return _imageWidget();
    } else {
      return FutureBuilder(
          future: widget.picture.download(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print("it's done:");
              return _imageWidget();
            } else if (snapshot.hasError) {
              FittedBox(
                child: Icon(
                  LineAwesomeIcons.exclamation_circle,
                  color: Theme.of(context).errorColor,
                ),
              );
            } else
              return SpinKitWave(color: Theme.of(context).primaryColor);
          });
    }
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
                  child: _getImage(),
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
