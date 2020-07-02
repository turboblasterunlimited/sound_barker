import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
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
        String stepText, bool stepIsCompleted, bool isCurrentStep, nextStep) {
      return RawMaterialButton(
        onPressed: stepIsCompleted
            ? () {
                // NAVIGATE to variable nextStep
              }
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

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          progressButton(
              "SNAP", card.hasPicture, currentActivity.isSnap, "SOME LOGIC"),
          progressButton(
              "SONG", card.hasSong, currentActivity.isSong, "SOME LOGIC"),
          progressButton(
              "SPEAK", card.hasBarks, currentActivity.isSong, "SOME LOGIC"),
          progressButton(
              "STYLE", card.hasDecoration, currentActivity.isStyle, "LOGIC"),
        ]);
  }
}
