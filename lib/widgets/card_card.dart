import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
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
  CurrentActivity currentActivity;

  @override
  void initState() {
    super.initState();
    imageController = Provider.of<ImageController>(context, listen: false);

    // animationController =
    //     AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  // @override
  // void dispose() {
  //   animationController.dispose();
  //   super.dispose();
  // }

  void handleTap() {
    widget.cards.setCurrent(widget.card);
    imageController.createDog(widget.card.picture);
    currentActivity.current = Activities.cardCreation;
    currentActivity.setCardCreationStep(
        CardCreationSteps.style, CardCreationSubSteps.three);
    Navigator.popUntil(
      context,
      ModalRoute.withName("main-screen"),
    );
  }

  Widget _decorationImageSelectable(image) {
    return (widget.card.decorationImage != null &&
            widget.card.decorationImage.hasFrameDimension)
        ? Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                    padding: EdgeInsets.only(
                      top: constraints.biggest.height * 72 / 778,
                      bottom: constraints.biggest.height * 194 / 778,
                      // left: 0,
                      // right: constraints.biggest.width * 72 / 656,
                    ),
                    child: image);
              },
            ),
          )
        : Positioned.fill(child: image);
  }

  Widget get _imageWidget {
    return Image.file(
      File(widget.card.picture.filePath),
    );
  }

  Widget _getImage() {
    Picture picture = widget.card.picture;
    if (picture.hasFile) {
      return _imageWidget;
    } else {
      return FutureBuilder(
        future: picture.download(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("it's done:");
            return _imageWidget;
          } else if (snapshot.hasError) {
            FittedBox(
              fit: BoxFit.cover,
              child: Icon(
                LineAwesomeIcons.exclamation_circle,
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

  Widget decorationImage() {
    return GridTile(
      child: GestureDetector(
        onTap: handleTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _decorationImageSelectable(
                  _getImage(),
                ),
                if (widget.card.decorationImage != null)
                  Image.file(
                    File(widget.card.decorationImage.filePath),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    // Animation animation = Tween(begin: 0.0, end: 1.0).animate(
    //     CurvedAnimation(parent: animationController, curve: Curves.ease));
    return decorationImage();
    // return AnimatedBuilder(
    //   key: widget.key,
    //   // animation: animation,
    //   child: decorationImage(),
    //   builder: (context, child) {
    //     return Transform.scale(
    //       scale: animation.value,
    //       child: child,
    //     );
    //   },
    // );
  }
}
