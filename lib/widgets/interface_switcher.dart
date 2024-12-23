import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/bark_recorder.dart';
import 'package:K9_Karaoke/widgets/bark_select_interface.dart';
import 'package:K9_Karaoke/widgets/card_frame_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_interface.dart';
import 'package:K9_Karaoke/widgets/personal_message_interface.dart';
import 'package:K9_Karaoke/widgets/mouth_interface.dart';
import 'package:K9_Karaoke/widgets/share_card_interface.dart';
import 'package:K9_Karaoke/widgets/song_arrangement_selector.dart';
import 'package:K9_Karaoke/widgets/song_playback_interface.dart';
import 'package:K9_Karaoke/widgets/song_select_interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InterfaceSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    KaraokeCard? card = Provider.of<KaraokeCards>(context).current != null
        ? Provider.of<KaraokeCards>(context).current
        : null;
    CurrentActivity currentActivity = Provider.of<CurrentActivity>(context);

    Widget _handleSpeakWidget() {
      if (currentActivity.isOne)
        return BarkRecorder();
      else if (currentActivity.isFive)
        return SongArrangementSelector();
      else if (currentActivity.isSix)
        return SongPlaybackInterface();
      else if (currentActivity.isSeven)
        return PersonalMessageInterface();
      else
        return BarkSelectInterface();
    }

    Widget? _handleStyleWidget() {
      if (currentActivity.isOne)
        return CardFrameInterface();
      else if (currentActivity.isTwo)
        return CardDecoratorInterface();
      else if (currentActivity.isThree) return ShareCardInterface();
    }

    return (currentActivity.isSnap && card != null && card.hasPicture)
        ? MouthInterface()
        : (currentActivity.isSong)
            ? SongSelectInterface()
            : (currentActivity.isSpeak)
                ? _handleSpeakWidget()
                : (currentActivity.isStyle)
                    ? _handleStyleWidget()!
                    : Center();
  }
}
