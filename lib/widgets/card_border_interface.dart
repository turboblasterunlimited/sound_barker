import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardBorderInterface extends StatefulWidget {
  @override
  _CardBorderInterfaceState createState() => _CardBorderInterfaceState();
}

class _CardBorderInterfaceState extends State<CardBorderInterface> {
  KaraokeCards cards;
  CurrentActivity currentActivity;

  void backCallback() {
    currentActivity.setCardCreationStep(CardCreationSteps.speak);
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.seven);
  }

  void skipCallback() {
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
  }

  @override
  Widget build(context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      children: <Widget>[
        interfaceTitleNav(context, "CHOOSE FRAME",
            backCallback: backCallback, skipCallback: skipCallback)
      ],
    );
  }
}
