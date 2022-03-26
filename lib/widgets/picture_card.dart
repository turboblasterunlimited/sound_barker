import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'dart:io';

import '../providers/pictures.dart';

class PictureCard extends StatefulWidget {
  final Picture picture;
  final Pictures pictures;
  List<Widget>? displayList;

  PictureCard(this.picture, this.pictures, this.displayList, {required Key key})
      : super(key: key);

  @override
  _PictureCardState createState() => _PictureCardState();
}

class _PictureCardState extends State<PictureCard>
    with TickerProviderStateMixin {
  late ImageController imageController;
  late AnimationController animationController;
  late Animation<double> animateScale;

  late KaraokeCards cards;
  late CurrentActivity currentActivity;

  @override
  void initState() {
    super.initState();
    imageController = Provider.of<ImageController>(context, listen: false);
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animateScale = Tween<double>(begin: 1, end: 0).animate(animationController);
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.picture.creationAnimation = false;
    animationController.dispose();
    super.dispose();
  }

  void imageActions(String action) async {
    if (action == "DELETE") {
      await animationController.forward();
      widget.displayList?.remove(this);
      await widget.pictures.remove(widget.picture);
    }
  }

  void handleTap() {
    print("dog name: ${widget.picture.name}");
    cards.setCurrentPicture(widget.picture);
    currentActivity.setCardCreationStep(CardCreationSteps.song);
    currentActivity.cardType =
        null; // needed when redoing card after save & send
    imageController.createDog(widget.picture);
    Navigator.popUntil(context, ModalRoute.withName(MainScreen.routeName));
  }

  Widget _imageWidget() {
    return Image.file(
      File(widget.picture.filePath!),
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
            return FittedBox(
              fit: BoxFit.cover,
              child: Icon(
                FontAwesomeIcons.exclamationCircle,
                color: Theme.of(context).errorColor,
                size: 50,
              ),
            );
          } else
            return SpinKitWave(color: Theme.of(context).primaryColor);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    print("animateScale: ${animateScale.value}");
    return Transform.scale(
      scale: animateScale.value,
      child: Container(
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
                Positioned(
                  right: -25,
                  top: -5,
                  child: Visibility(
                    visible: !widget.picture.isStock!,
                    child: Stack(
                      children: <Widget>[
                        PopupMenuButton(
                          onSelected: imageActions,
                          child: RawMaterialButton(
                            onPressed: null,
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
      ),
    );
  }
}
