import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardFrameInterface extends StatefulWidget {
  @override
  _CardFrameInterfaceState createState() => _CardFrameInterfaceState();
}

class _CardFrameInterfaceState extends State<CardFrameInterface> {
  KaraokeCards cards;
  CurrentActivity currentActivity;
  String selectedFrame;

  void backCallback() {
    currentActivity.setCardCreationStep(CardCreationSteps.speak);
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.seven);
  }

  void skipCallback() {
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
    Future.delayed(Duration(milliseconds: 500), () => cards.setFrame(null));
  }

  String rootPath = "assets/card_borders/";

  List frameFileNames = ['white.png', 'black.png', 'magenta.png', 'teal.png', 'red.png', 'blue.png'];

  Widget frameSelectable(fileName) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = fileName);
        cards.setFrame(rootPath + fileName);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: selectedFrame == fileName
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
              )
            : BoxDecoration(),
        child: SizedBox(
          child: Image.asset(rootPath + fileName),
        ),
      ),
    );
  }

  Widget frameList() {
    return Center(
      child: Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          itemCount: frameFileNames.length,
          itemBuilder: (ctx, i) => frameSelectable(frameFileNames[i]),
        ),
      ),
    );
  }

  Widget submitButton() {
    return Center(
      child: RawMaterialButton(
        onPressed: cards.hasFrame
            ? () {
                currentActivity
                    .setCardCreationSubStep(CardCreationSubSteps.two);
              }
            : null,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor:
            cards.hasFrame ? Theme.of(context).primaryColor : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0),
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
        submitButton(),
      ],
    );
  }
}
