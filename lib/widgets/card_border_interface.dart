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
  String selectedFrame;

  void backCallback() {
    currentActivity.setCardCreationStep(CardCreationSteps.speak);
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.seven);
  }

  void skipCallback() {
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
  }

  String rootPath = "assets/card_borders/";

  List frameFileNames = ['white.png', 'black.png', 'magenta.png', 'teal.png'];

  Widget frameSelectable(fileName) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = fileName);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: selectedFrame == fileName ? 3 : 0,
          ),
        ),
        child: FittedBox(
          child: Image.asset(rootPath + fileName),
        ),
      ),
    );
  }

  Widget frameList() {
    return Center(
      child: Container(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          itemCount: frameFileNames.length,
          itemBuilder: (ctx, i) => frameSelectable(frameFileNames[i]),
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      children: <Widget>[
        interfaceTitleNav(context, "CHOOSE FRAME",
            backCallback: backCallback, skipCallback: skipCallback),
        frameList(),
      ],
    );
  }
}
