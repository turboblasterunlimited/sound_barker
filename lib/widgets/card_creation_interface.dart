import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_recorder.dart';
import 'package:K9_Karaoke/widgets/bark_select_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_interface.dart';
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

    return Expanded(
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
        ),
        Visibility(
          visible: currentActivity.isSnap && card.hasPicture,
          child: MouthToneSlider(),
        ),
        Visibility(
          visible: currentActivity.isSong,
          child: SongSelectInterface(),
        ),
        Visibility(
          visible: currentActivity.isSpeak,
          child: currentActivity.isOne ? BarkRecorder() : BarkSelectInterface(),
        ),
        // Visibility(
        //   visible: currentActivity.isStyle,
        //   child: CardDecoratorInterface(),
        // ),
      ]),
    );
  }
}
