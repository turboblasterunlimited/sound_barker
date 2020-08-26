import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'dart:io';

class CardCard extends StatefulWidget {
  final KaraokeCard card;
  final KaraokeCards cards;
  CardCard(this.card, this.cards, {Key key}) : super(key: key);

  @override
  _CardCardState createState() => _CardCardState();
}

class _CardCardState extends State<CardCard> with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void imageActions(String action) {
    if (action == "DELETE") {
      animationController.reverse();
      widget.cards.remove(widget.card);
    } else if (action == "SHARE/EDIT") {
      handleTap();
    }
  }

  void handleTap() {
    cards.setCurrent(widget.card);
    imageController.createDog(widget.card.picture);
    Navigator.popUntil(
      context,
      ModalRoute.withName("main-screen"),
    );
  }

  Widget decorationImageSelectable(image) {
    return widget.card.decorationImage.hasFrameDimension
        ? Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                    padding: EdgeInsets.only(
                      top: constraints.biggest.height * 72 / 778,
                      bottom: constraints.biggest.height * 194 / 778,
                      left: constraints.biggest.width * 72 / 656,
                      right: constraints.biggest.width * 72 / 656,
                    ),
                    child: image);
              },
            ),
          )
        : Positioned.fill(child: image);
  }

  Widget decorationImage() {
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          child: Stack(
            children: [
              decorationImageSelectable(
                Image.file(File(cards.current.picture.filePath)),
              ),
              Image.file(
                File(cards.current.decorationImage.filePath),
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
                            value: "DELETE",
                            child: Text("Delete"),
                          ),
                          PopupMenuItem<String>(
                            value: "SHARE/EDIT",
                            child: Text("Share/Edit"),
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
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    Animation animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));

    return AnimatedBuilder(
      key: widget.key,
      animation: animation,
      child: decorationImage(),
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: child,
        );
      },
    );
  }
}
