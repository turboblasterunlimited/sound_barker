import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/mouth_tone_slider.dart';
import 'package:K9_Karaoke/widgets/song_select_interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardCreationInterface extends StatelessWidget {
  KaraokeCard card;
  CurrentActivity currentActivity;
  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context).currentCard;
    currentActivity = Provider.of<CurrentActivity>(context);
    print("current activity is song: ${currentActivity.isSong}");

    return Expanded(
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
        ),
        Visibility(
          visible: currentActivity.isSnap,
          child: MouthToneSlider(),
        ),
        Visibility(
          visible: currentActivity.isSong,
          child: SongSelectInterface(),
        ),
        Visibility(
          visible: currentActivity.isSpeak,
          child: SongSelectInterface(),
        ),
        Visibility(
          visible: currentActivity.isStyle,
          child: SongSelectInterface(),
        ),
      ]),
    );
  }
}
