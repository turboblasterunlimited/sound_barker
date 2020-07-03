  import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/mouth_tone_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardCreationInterface extends StatelessWidget {
  KaraokeCard card;
  CurrentActivity currentActivity;
  @override
  Widget build(BuildContext context) {
    card = Provider.of<KaraokeCards>(context).currentCard;
    currentActivity = Provider.of<CurrentActivity>(context);
    
    return Column(
        children: <Widget>[
          Visibility(visible: currentActivity.isSnap, child: MouthToneSlider(),),
          // Visibility(visible: child: ,)
        ]);
  }
}