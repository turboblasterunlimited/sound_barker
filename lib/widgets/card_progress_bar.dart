import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardProgressBar extends StatelessWidget {
  KaraokeCard card;
  CurrentActivity currentActivity;

  bool cardPictureIsStock() {
    return card.hasPicture ? !card.picture.isStock : false;
  }

  bool get _hasDecoration {
    return card.decorationImage != null || !card.decoration.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context, listen: false).current;
    currentActivity = Provider.of<CurrentActivity>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth / 5;

    Widget progressButton(
        {IconData stepIcon,
        bool stepIsCompleted,
        bool isCurrentStep,
        Function navigateHere,
        bool canNavigate}) {
      return Opacity(
        opacity: canNavigate ? 1 : .3,
        child: RawMaterialButton(
          constraints: BoxConstraints(minWidth: buttonWidth, minHeight: 30.0),
          onPressed: canNavigate ? navigateHere : null,
          child: Icon(
            stepIcon,
            color:
                stepIsCompleted ? Colors.white : Theme.of(context).primaryColor,
          ),
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
      if (card.picture.isStock)
        Navigator.of(context).pushNamed(PhotoLibraryScreen.routeName);
      else
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SetPictureCoordinatesScreen(card.picture, editing: true),
          ),
        );
      if (!card.picture.isStock)
        currentActivity.setCardCreationStep(CardCreationSteps.snap);
    }

    void navigateToSong() {
      currentActivity.setCardCreationStep(CardCreationSteps.song);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
    }

    void navigateToSpeak() {
      if (card.hasSong) {
        currentActivity.setCardCreationStep(
            CardCreationSteps.speak, CardCreationSubSteps.seven);
      } else if (card.hasSongFormula)
        currentActivity.setCardCreationStep(CardCreationSteps.speak);
      else
        currentActivity.setCardCreationStep(
            CardCreationSteps.speak, CardCreationSubSteps.seven);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
    }

    void navigateToStyle() {
      currentActivity.setCardCreationStep(CardCreationSteps.style);
      // This is in case SetCoordinatesScreen is on the stack.
      Navigator.of(context).popUntil(ModalRoute.withName("main-screen"));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        progressButton(
            stepIcon: CustomIcons.snap_quick,
            stepIsCompleted: card.hasPicture,
            isCurrentStep: currentActivity.isSnap,
            navigateHere: navigateToSnap,
            canNavigate: true),
        progressButton(
            stepIcon: CustomIcons.song_quick,
            stepIsCompleted: card.hasSong || card.hasSongFormula,
            isCurrentStep: currentActivity.isSong,
            navigateHere: navigateToSong,
            canNavigate: card.hasPicture),
        // Can click only if creating a new song
        progressButton(
            stepIcon: CustomIcons.speak_quick,
            stepIsCompleted: card.hasMessage,
            isCurrentStep: currentActivity.isSpeak,
            navigateHere: navigateToSpeak,
            // canNavigate: card.hasSongFormula || card.hasSong),
            canNavigate: card.hasPicture),
        progressButton(
            stepIcon: CustomIcons.style_quick,
            stepIsCompleted: _hasDecoration,
            isCurrentStep: currentActivity.isStyle,
            navigateHere: navigateToStyle,
            canNavigate: card.hasAudio),
      ],
    );
  }
}
