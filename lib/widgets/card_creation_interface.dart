import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_recorder.dart';
import 'package:K9_Karaoke/widgets/bark_select_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_interface.dart';
import 'package:K9_Karaoke/widgets/mouth_tone_slider.dart';
import 'package:K9_Karaoke/widgets/song_arrangement_selector.dart';
import 'package:K9_Karaoke/widgets/song_playback_interface.dart';
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
        if (currentActivity.isSnap && card.hasPicture)
          MouthToneSlider(),
        if (currentActivity.isSong)
          SongSelectInterface(),
        if (currentActivity.isSpeak && currentActivity.isOne)
          BarkRecorder()
        else if (currentActivity.isSpeak && currentActivity.isFive) 
          SongArrangementSelector()
        else if (currentActivity.isSpeak && currentActivity.isSix) 
          SongPlaybackInterface()
        else if (currentActivity.isSpeak)
          BarkSelectInterface(),
        if (false)
          Center(),
        
        // Visibility(
        //   visible: currentActivity.isStyle,
        //   child: CardDecoratorInterface(),
        // ),
      ]),
    );
  }
}
