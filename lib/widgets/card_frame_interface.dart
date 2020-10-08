import 'dart:io';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
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
  ImageController imageController;
  SoundController soundController;
  String selectedFrameCategory = "Birthday";
  List<Widget> currentFrameCategories;

  @override
  void dispose() {
    imageController.stopAnimation();
    soundController.stopPlayer();
    super.dispose();
  }

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

  List<Widget> getFrameCategories() {
    return [
      Text('Birthday', style: TextStyle(fontSize: 15)),
      Text('Christmas', style: TextStyle(fontSize: 15)),
      Text('Jewish', style: TextStyle(fontSize: 15)),
      Text('New Years', style: TextStyle(fontSize: 15)),
      Text('USA Holidays', style: TextStyle(fontSize: 15)),
      Text('Other Holidays', style: TextStyle(fontSize: 15)),
      Text('Sports', style: TextStyle(fontSize: 15)),
      Text('Themes', style: TextStyle(fontSize: 15)),
      Text('Designs', style: TextStyle(fontSize: 15)),
    ];
  }

  Map<String, List<String>> frameFileNames = {
    "Birthday": [
      'birthday-bone.png',
      'birthday-4.png',
      'birthday-1.png',
      'birthday-2.png',
      'birthday-3.png',
      'birthday-package.png',
      'birthday-package-blue.png',
      'birthday-package-orange.png',
      'birthday-package-pink.png',
    ],
    "Christmas": [
      "christmas-package.png",
      'christmas-santa.png',
      'christmas-gifts.png',
      'christmas-ornaments.png',
      'christmas-wreath.png',
    ],
    "Jewish": [
      'hanukkah-dreidel.png',
      'hanukkah-dreidel2.png',
      'hanukkah-package.png',
      'kiddush-cup.png',
      'torah.png',
    ],
    "New Years": [
      'new-year-baby.png',
      'new-year-cat.png',
      'new-year-dog.png',
      'new-year-champagne.png',
      'new-year-fireworks.png',
    ],
    "USA Holidays": [
      'july-4th.png',
      'liberty-flag.png',
      'fireworks.png',
      'flag.png',
      'liberty.png',
      'liberty-flag-4th1.png',
      'flag-4th2.png'
    ],
    "Other Holidays": [
      'thanksgiving.png',
      'halloween.png',
      'easter.png',
      'fathers-day.png',
      'mothers-day.png',
      'valentine.png',
    ],
    "Sports": [
      'baseball.png',
      'basketball.png',
      'football.png',
      'hockey.png',
      'soccer.png',

    ],
    "Themes": [
      '50s.png',
      'beach.png',
      'farm.png',
      'flowers.png',
      'ocean.png',
      'space.png',
      'odor.png',
    ],
    "Designs": [
      'abstract1.png',
      'abstract2.png',
      'abstract3.png',
      'abstract4.png',
      'abstract-rainbow.png',
      'abstract-psychedelic.png',
      'color-white.png',
      'color-black.png',
      'color-magenta.png',
      'color-teal.png',
      'color-red.png',
      'color-blue.png',
    ],
  };

  Widget frameSelectable(fileName) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = fileName);
        cards.setFrame(rootPath + fileName);
        cards.current.setShouldDeleteOldDecortionImage();
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
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
            alignment: AlignmentDirectional.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: constraints.biggest.height * 72 / 778,
                      bottom: constraints.biggest.height * 194 / 778,
                    ),
                    child: Image.file(
                      File(cards.current.picture.filePath),
                    ),
                  );
                },
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
        SystemChrome.setEnabledSystemUIOverlays([]);
        cards.current.setShouldDeleteOldDecortionImage();
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

  Widget decorationImageSelectable(image) {
    return cards.current.hasFrameDimension
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                  padding: EdgeInsets.only(
                    top: constraints.biggest.height * 72 / 778,
                    bottom: constraints.biggest.height * 194 / 778,
                  ),
                  child: image);
            },
          )
        : image;
  }

  Widget decorationImage() {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFrame = "decorationImage");
        cards.setFrame(null);
        cards.current.shouldDeleteOldDecoration = false;
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
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
            alignment: AlignmentDirectional.center,
            children: [
              decorationImageSelectable(
                Image.file(File(cards.current.picture.filePath)),
              ),
              Image.file(
                File(cards.current.decorationImage.filePath),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetSizes(List<Widget> categories) {
    for (var i = 0; i < currentFrameCategories.length; i++) {
      currentFrameCategories[i] = categories[i];
    }
  }

  void _handleCategoryChange(index) {
    var categories = getFrameCategories();
    var selectedWidget = categories[index] as Text;
    String label = selectedWidget.data;
    setState(() {
      _resetSizes(categories);
      currentFrameCategories[index] = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ],
      );
      selectedFrameCategory = label;
    });
  }

  Widget categoryList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: CarouselSlider(
        items: currentFrameCategories,
        options: CarouselOptions(
          enlargeCenterPage: true,
          onPageChanged: (index, CarouselPageChangedReason reason) {
            _handleCategoryChange(index);
          },
          scrollPhysics: FixedExtentScrollPhysics(),
          initialPage: 0,
          height: 30,
          viewportFraction: 0.4,
        ),
      ),
    );
  }

  Widget frameList() {
    // first item should be no frame, and second is decoration image if exists.
    var iOffset = cards.current.decorationImage == null ? 1 : 2;
    return Center(
      child: Container(
        height: 140,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 778 / 656,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) {
                  if (i == 0)
                    return noFrame();
                  else if (i == 1 && cards.current.decorationImage != null)
                    return decorationImage();
                  else
                    return frameSelectable(
                        frameFileNames[selectedFrameCategory][i - iOffset]);
                },
                childCount:
                    frameFileNames[selectedFrameCategory].length + iOffset,
              ),
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
      child: MaterialButton(
        height: 20,
        minWidth: 50,
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
        color: selectedFrame != null
            ? Theme.of(context).primaryColor
            : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0),
      ),
    );
  }

  void _setFrameSelection() {
    if (cards.current.isUsingDecorationImage)
      selectedFrame = "decorationImage";
    else if (cards.current.framePath != null)
      selectedFrame = PATH.basename(cards.current.framePath);
  }

  @override
  Widget build(context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    imageController = Provider.of<ImageController>(context, listen: false);
    soundController = Provider.of<SoundController>(context, listen: false);
    if (currentFrameCategories == null) {
      currentFrameCategories = getFrameCategories();
      _handleCategoryChange(0);
    }
    _setFrameSelection();

    return Column(
      children: <Widget>[
        interfaceTitleNav(context, "CHOOSE ART",
            backCallback: backCallback, skipCallback: skipCallback),
        // Divider(
        //   color: Theme.of(context).primaryColor,
        //   thickness: 3,
        // ),
        categoryList(),
        frameList(),
        submitButton(),
      ],
    );
  }
}
