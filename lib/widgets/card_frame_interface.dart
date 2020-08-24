import 'dart:io';
import 'package:path/path.dart' as PATH;

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
    if (cards.current.decorationImage != null) {
      cards.current.shouldDeleteOldDecoration = false;
      Future.delayed(
          Duration(milliseconds: 200),
          () => currentActivity
              .setCardCreationSubStep(CardCreationSubSteps.three));
    } else {
      currentActivity.setNextSubStep();
      Future.delayed(Duration(milliseconds: 500), () => cards.setFrame(null));
    }
  }

  String rootPath = "assets/card_borders/";

  List frameFileNames = [
    'white.png',
    'black.png',
    'magenta.png',
    'teal.png',
    'red.png',
    'blue.png',
    'bd-balloons.png',
    'bd-bone.png',
    'bd-cake-1.png',
    'bd-cake-2.png',
    'bd-cake-3.png',
    'pres-1.png',
    'pres-2.png',
    'pres-3.png',
    'pres-hannuka.png',
    'pres-xmas.png',
  ];

  Widget frameSelectable(fileName) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = fileName);
        cards.setFrame(rootPath + fileName);
        cards.current.shouldDeleteOldDecoration = true;
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
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: constraints.biggest.height * 72 / 778,
                        bottom: constraints.biggest.height * 194 / 778,
                        left: constraints.biggest.width * 72 / 656,
                        right: constraints.biggest.width * 72 / 656,
                      ),
                      child: Image.file(
                        File(cards.current.picture.filePath),
                      ),
                    );
                  },
                ),
              ),
              Image.asset(rootPath + fileName),
            ],
          ),
        ),
      ),
    );
  }

  Widget noFrame() {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = "");
        cards.setFrame(null);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: selectedFrame == ""
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
              )
            : BoxDecoration(),
        child: SizedBox(
          child: Column(
            children: [
              Expanded(child: Image.file(File(cards.current.picture.filePath))),
              Center(child: Text("No Frame")),
            ],
          ),
        ),
      ),
    );
  }

  Widget decorationImage() {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = "decorationImage");
        cards.setFrame(null);
        cards.current.shouldDeleteOldDecoration = false;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: selectedFrame == "decorationImage"
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
              )
            : BoxDecoration(),
        child: SizedBox(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: constraints.biggest.height * 72 / 778,
                        bottom: constraints.biggest.height * 194 / 778,
                        left: constraints.biggest.width * 72 / 656,
                        right: constraints.biggest.width * 72 / 656,
                      ),
                      child: Image.file(
                        File(cards.current.picture.filePath),
                      ),
                    );
                  },
                ),
              ),
              Image.file(File(cards.current.decorationImage.filePath)),
            ],
          ),
        ),
      ),
    );
  }

  int get listLength {
    return frameFileNames.length +
        (cards.current.decorationImage != null ? 2 : 1);
  }

  Widget frameList() {
    return Center(
      child: Container(
        height: 100,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: <Widget>[
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int i) {
                if (i >= listLength - 1)
                  return null;
                else if (i == 0)
                  return noFrame();
                else if (i == 1 && cards.current.decorationImage != null)
                  return decorationImage();
                else
                  return frameSelectable(frameFileNames[i]);
              }),
            ),
          ],
        ),
      ),
    );
  }

  bool get _keepingCardDecorationImage {
    return cards.current.decorationImage != null &&
        !cards.current.shouldDeleteOldDecoration;
  }

  // bool get _noFrameNoDecorationImage {
  //   return cards.current.decorationImage == null &&
  //       cards.current.framePath == null;
  // }

  Widget submitButton() {
    return Center(
      child: RawMaterialButton(
        onPressed: _keepingCardDecorationImage
            ? () => currentActivity
                .setCardCreationSubStep(CardCreationSubSteps.three)
            : currentActivity.setNextSubStep,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 2.0,
        fillColor: selectedFrame != null
            ? Theme.of(context).primaryColor
            : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0),
      ),
    );
  }

  void _setFrameSelection() {
    if (cards.current.framePath != null)
      selectedFrame = PATH.basename(cards.current.framePath);
  }

  @override
  Widget build(context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    _setFrameSelection();
    return Column(
      children: <Widget>[
        interfaceTitleNav(context, "CHOOSE ART",
            backCallback: backCallback, skipCallback: skipCallback),
        frameList(),
        submitButton(),
      ],
    );
  }
}
