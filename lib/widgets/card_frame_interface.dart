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
  int _currentFrameCategoryIndex = 0;
  ImageController imageController;
  SoundController soundController;
  List<Widget> currentFrameCategories;
  final _carouselController = CarouselController();
  final _scrollController = ScrollController();
  double _listItemWidth;
  bool userManipulatingCategory = false;

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

  // Text string and Map Keys must match.
  // needs to be a method so widgets wont be mutated.
  List<Widget> getFrameCategories() {
    return [
      Text('Birthday', style: TextStyle(fontSize: 15)),
      Text('Christmas', style: TextStyle(fontSize: 15)),
      Text('Jewish', style: TextStyle(fontSize: 15)),
      Text('New Years', style: TextStyle(fontSize: 15)),
      Text('USA Holidays', style: TextStyle(fontSize: 15)),
      Text('Holidays', style: TextStyle(fontSize: 15)),
      Text('Sports', style: TextStyle(fontSize: 15)),
      Text('Themes', style: TextStyle(fontSize: 15)),
      Text('Designs', style: TextStyle(fontSize: 15)),
      Text('Simple', style: TextStyle(fontSize: 15)),
    ];
  }

  Map<String, List<String>> frameFileNames = {
    "Birthday": [
      'no-frame',
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
    "Holidays": [
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
    "Simple": [
      'color-white.png',
      'color-black.png',
      'color-magenta.png',
      'color-teal.png',
      'color-red.png',
      'color-blue.png',
    ],
  };

  Widget frameSelectable(fileName) {
    if (fileName == "no-frame") return noFrame();
    if (fileName == "existing-art") return decorationImage();
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
                builder: (_, constraints) {
                  // if (_listItemWidth == null)
                  _listItemWidth ??= constraints.biggest.width;
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

  Widget _frameLabel(text) {
    return Positioned(
      bottom: 5,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
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
        decoration: selectedFrame == ""
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
              Image.file(
                File(cards.current.picture.filePath),
              ),
              _frameLabel("No Frame"),
            ],
          ),
        ),
      ),
    );
  }

  Widget decorationImageSelectable(image) {
    return cards.current.decorationImage.hasFrameDimension
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
        setState(() => selectedFrame = "existing-art");
        cards.setFrame(null, cards.current.decorationImage.hasFrameDimension);
        cards.current.shouldDeleteOldDecoration = false;
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
        decoration: selectedFrame == "existing-art"
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
              _frameLabel("Current Art")
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

  void _handleCategoryChange(frameCategoryIndex, {int frameIndex}) {
    print("checkpoint");
    var categories = getFrameCategories();
    var selectedCategoryWidget = categories[frameCategoryIndex] as Text;
    String label = selectedCategoryWidget.data;
    Future.delayed(
      Duration(milliseconds: 100),
      () => setState(
        () {
          _currentFrameCategoryIndex = frameCategoryIndex;
          _resetSizes(categories);
          currentFrameCategories[frameCategoryIndex] = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ],
          );
        },
      ),
    );
    // category is selected (vs frame scrolling)
    if (frameIndex != null)
      _scrollController.jumpTo(frameIndex * (_listItemWidth + 5));
  }

  void _handleCarouselSlider(index) {
    int frameIndex = _categoryIndexToFrameIndex(index);
    // print("frame index selected: $frameIndex");
    _handleCategoryChange(index, frameIndex: frameIndex);
  }

  Widget categoryList() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: CarouselSlider(
            carouselController: _carouselController,
            items: currentFrameCategories,
            options: CarouselOptions(
              enlargeCenterPage: true,
              onPageChanged: (index, CarouselPageChangedReason reason) {
                print("reason for carousel change: ${reason.toString()}");
                if (reason == CarouselPageChangedReason.manual) {
                  setState(() => userManipulatingCategory = true);
                  _handleCarouselSlider(index);
                  setState(() => userManipulatingCategory = false);
                }
              },
              scrollPhysics: FixedExtentScrollPhysics(),
              initialPage: 0,
              height: 30,
              viewportFraction: 0.4,
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _carouselController.previousPage(reasonIsController: false);
              // _handleCategoryChange(_currentFrameCategoryIndex - 1);
            },
            onPanStart: (_) =>
                _carouselController.previousPage(reasonIsController: false),
            child: Container(width: 65, height: 25),
          ),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _carouselController.nextPage(reasonIsController: false);
              // _handleCategoryChange(_currentFrameCategoryIndex + 1);
            },
            onPanStart: (_) =>
                _carouselController.nextPage(reasonIsController: false),
            child: Container(width: 65, height: 25),
          ),
        ),
      ],
    );
  }

  List<String> get _allFrames {
    return frameFileNames.values.expand((element) => element).toList();
  }

  int get _framesCount {
    return _allFrames.length;
  }

  List<int> get _frameCategoryCounts {
    return frameFileNames.values.map((cat) => cat.length).toList();
  }

  List<String> get _frameCategories {
    return frameFileNames.keys.toList();
  }

  int get _categoriesCount {
    return _frameCategories.length;
  }

  int _frameIndexToCategoryIndex(int frameIndex) {
    int frameCount = 0;
    for (int categoryIndex = 0;
        categoryIndex < _categoriesCount;
        categoryIndex++) {
      frameCount += _frameCategoryCounts[categoryIndex];
      if (frameCount > frameIndex) return categoryIndex;
    }
  }

  int _categoryIndexToFrameIndex(int selectedCategoryIndex) {
    int frameCount = 0;
    for (int categoryIndex = 0;
        categoryIndex < _categoriesCount;
        categoryIndex++) {
      if (categoryIndex == selectedCategoryIndex) return frameCount;
      frameCount += _frameCategoryCounts[categoryIndex];
    }
  }

  int _pixelsToFrameIndex(double pixels) {
    // rendered item width + list padding
    var itemWidth = _listItemWidth + 5;
    return (pixels / itemWidth % _framesCount).round();
  }

  void _handleCarouselDirection(bool moveForward) {
    moveForward
        ? _carouselController.nextPage()
        : _carouselController.previousPage();
  }

  // prevents animating through all categories between first and last categories on the carousel
  void animateToPage(frameCategoryIndex) {
    if (frameCategoryIndex == null) return;
    // transitioning from last category to first category
    if (_currentFrameCategoryIndex == _categoriesCount - 1 &&
        frameCategoryIndex == 0)
      _carouselController.nextPage();
    // transitioning from first category to last category
    else if (_currentFrameCategoryIndex == 0 &&
        frameCategoryIndex == _categoriesCount - 1)
      _carouselController.previousPage();
    else
      _carouselController.animateToPage(frameCategoryIndex);
  }

  Widget frameList() {
    // first item should be no frame, and second is decoration image if exists.
    var iOffset = cards.current.decorationImage == null ? 1 : 2;
    return Center(
      child: Container(
        height: 140,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            var pixels = notification.metrics.pixels;
            var frameIndex = _pixelsToFrameIndex(pixels);
            int frameCategoryIndex = _frameIndexToCategoryIndex(frameIndex);
            print("frame index: $frameIndex");
            print("current category index: $_currentFrameCategoryIndex");
            print("new category index: $frameCategoryIndex");
            if (frameCategoryIndex != _currentFrameCategoryIndex &&
                !userManipulatingCategory) {
              animateToPage(frameCategoryIndex);
              _handleCategoryChange(frameCategoryIndex);
            }
            return null;
          },
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            slivers: <Widget>[
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 778 / 656,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext _, int scrollIndex) {
                    int frameIndex = scrollIndex % _framesCount;
                    return frameSelectable(_allFrames[frameIndex]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _keepingCardDecorationImage {
    return cards.current.decorationImage != null &&
        !cards.current.shouldDeleteOldDecoration;
  }

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
      selectedFrame = "existing-art";
    else if (cards.current.framePath != null)
      selectedFrame = PATH.basename(cards.current.framePath);
  }

  void _insertIfExistingArtFrame() {
    if (cards.current.decorationImage != null)
      frameFileNames["Birthday"].insert(1, "existing-art");
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
      _insertIfExistingArtFrame();
    }
    _setFrameSelection();

    return Column(
      children: <Widget>[
        InterfaceTitleNav("CHOOSE FRAME",
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
