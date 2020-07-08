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

    Widget progressButton(String stepText, bool stepIsCompleted,
        bool isCurrentStep, Function navigateHere, bool canNavigate) {
      return Opacity(
        opacity: canNavigate ? 1 : .3,
        child: RawMaterialButton(
          onPressed: canNavigate ? navigateHere : null,
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
                  : BorderSide(
                      color: Theme.of(context).primaryColor, width: 5)),
          elevation: stepIsCompleted ? 5.0 : 0,
          fillColor: stepIsCompleted
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
        ),
      );
    }

    void navigateToSnap() {
      currentActivity.setCardCreationStep(CardCreationSteps.snap);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(card.picture, editing: true),
        ),
      );
    }

    void navigateToSong() {
      currentActivity.setCardCreationStep(CardCreationSteps.song);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("/"));
    }

    void navigateToSpeak() {
      currentActivity.setCardCreationStep(CardCreationSteps.speak);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("/"));
    }

    void navigateToStyle() {
      currentActivity.setCardCreationStep(CardCreationSteps.style);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("/"));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          progressButton("SNAP", card.hasPicture, currentActivity.isSnap,
              navigateToSnap, true),
          progressButton("SONG", card.hasSong, currentActivity.isSong,
              navigateToSong, card.hasPicture),
          progressButton("SPEAK", card.hasBarks, currentActivity.isSpeak,
              navigateToSpeak, card.hasSong),
          progressButton("STYLE", card.hasDecoration, currentActivity.isStyle,
              navigateToStyle, card.hasBarks),
        ]);
  }
}
