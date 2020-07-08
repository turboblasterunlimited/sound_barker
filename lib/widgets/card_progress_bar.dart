import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardProgressBar extends StatelessWidget {
  KaraokeCard card;
  CurrentActivity currentActivity;
  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context).currentCard;
    currentActivity = Provider.of<CurrentActivity>(context);

    Widget progressButton(
        String stepText, bool stepIsCompleted, bool isCurrentStep, Function navigateHere) {
      return RawMaterialButton(
        onPressed: stepIsCompleted
            ? navigateHere
            : null,
        child: Text(stepText,
            style: TextStyle(
                color: stepIsCompleted
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: isCurrentStep
                ? BorderSide(color: Colors.blue, width: 5)
                : BorderSide(color: Theme.of(context).primaryColor, width: 5)),
        elevation: 5.0,
        fillColor: stepIsCompleted
            ? Theme.of(context).primaryColor
            : Colors.transparent,
        // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      );
    }

    void navigateToSnap() {
      currentActivity.setCardCreationStep(CardCreationSteps.snap);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SetPictureCoordinatesScreen(card.picture, editing: true),
        ),
      );
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          progressButton(
              "SNAP", card.hasPicture, currentActivity.isSnap, navigateToSnap),
          progressButton(
              "SONG", card.hasSong, currentActivity.isSong, () {}),
          progressButton(
              "SPEAK", card.hasBarks, currentActivity.isSpeak, () {}),
          progressButton(
              "STYLE", card.hasDecoration, currentActivity.isStyle, () {}),
        ]);
  }
}
