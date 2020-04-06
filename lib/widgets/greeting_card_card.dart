import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'dart:io';

import '../providers/greeting_cards.dart';

class GreetingCardCard extends StatefulWidget {
  final int index;
  final GreetingCard card;
  final GreetingCards cards;
  GreetingCardCard(this.index, this.card, this.cards, {Key key})
      : super(key: key);

  @override
  _GreetingCardCardState createState() => _GreetingCardCardState();
}

class _GreetingCardCardState extends State<GreetingCardCard> with TickerProviderStateMixin {
  ImageController imageController;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // If was just created, animate in. Otherwise, don't.
    if (widget.card.creationAnimation) {
      animationController.forward();
    } else {
      animationController.forward(from: 1.0);
    }
  }

  @override
  void dispose() {
    widget.card.creationAnimation = false;
    animationController.dispose();
    super.dispose();
  }

  void imageActions(String action) {
    if (action == "DELETE") {
    } else if (action == "SHARE") {}
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
                  // HIDE WEBVIEW, SHOW VIDEO SCREEN
                  // PLAYBACK VIDEO
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(widget.card.filePath),
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
                            value: "SHARE",
                            child: Text("SHARE"),
                          ),
                          PopupMenuItem<String>(
                            value: "DELETE",
                            child: Text("DELETE"),
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
