import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_recorder.dart';
import 'package:K9_Karaoke/widgets/bark_select_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_interface.dart';
import 'package:K9_Karaoke/widgets/human_message_recorder.dart';
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
    card = Provider.of<KaraokeCards>(context).current;
    currentActivity = Provider.of<CurrentActivity>(context);

    Widget _handleSpeakWidget() {
      if (currentActivity.isOne)
        return BarkRecorder();
      else if (currentActivity.isFive)
        return SongArrangementSelector();
      else if (currentActivity.isSix)
        return SongPlaybackInterface();
      else if (currentActivity.isSeven)
        return HumanMessageRecorder();
      else
        BarkSelectInterface();
    }

    Widget _handleStyleWidget() {
      // if (currentActivity.isOne)
      //   return CardBorderSelectionInterface();
      // else if (currentActivity.isTwo)
      //   return CardDecorcatorInterface();
      // else if (currentActivity.isThree)
      //   return ShareCardInterface();
    }

    return Expanded(
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
        ),
        if (currentActivity.isSnap && card.hasPicture)
          MouthToneSlider(),
        if (currentActivity.isSong)
          SongSelectInterface(),
        if (currentActivity.isSpeak)
          _handleSpeakWidget(),
        if (currentActivity.isStyle)
          _handleStyleWidget(),
        

        // Visibility(
        //   visible: currentActivity.isStyle,
        //   child: CardDecoratorInterface(),
        // ),
      ]),
    );
  }
}
