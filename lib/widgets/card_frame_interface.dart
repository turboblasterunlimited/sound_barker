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
import 'package:K9_Karaoke/globals.dart';

class CardFrameInterface extends StatefulWidget {
  @override
  _CardFrameInterfaceState createState() => _CardFrameInterfaceState();
}

class _CardFrameInterfaceState extends State<CardFrameInterface> {
  KaraokeCards cards;
  CurrentActivity currentActivity;
  String selectedFrame = "";
  int _currentFrameCategoryIndex = 0;
  ImageController imageController;
  SoundController soundController;
  List<Widget> currentFrameCategories;
  final _carouselController = CarouselController();
  final _scrollController = ScrollController();
  double _listItemWidth;
  bool userManipulatingCategory = false;
  bool firstBuild = true;
  Map<String, List<String>> frameFiles = frameFileNames;
  double halfScreenWidth;

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
    print("Card framepath: ${cards.current.framePath}");
    print("card decoration image: ${cards.current.decorationImage}");
    if (cards.current.decorationImage != null) {
      cards.current.shouldDeleteOldDecoration = false;
      Future.delayed(
          Duration(milliseconds: 200),
          () => currentActivity
              .setCardCreationSubStep(CardCreationSubSteps.three));
    } else {
      currentActivity.setNextSubStep();
      Future.delayed(
          Duration(milliseconds: 500), () => setFrame(noFrame: true));
    }
  }

  // Text string and Map Keys must match.
  // needs to be a method so widgets wont be mutated.
  List<Widget> getFrameCategories() {
    return [
      Text('Birthday', style: TextStyle(fontSize: 15)),
      Text('Greetings', style: TextStyle(fontSize: 15)),
      Text('Christmas', style: TextStyle(fontSize: 15)),
      Text('Jewish', style: TextStyle(fontSize: 15)),
      Text('New Years', style: TextStyle(fontSize: 15)),
      Text('Holidays', style: TextStyle(fontSize: 15)),
      Text('National', style: TextStyle(fontSize: 15)),
      Text('Kids', style: TextStyle(fontSize: 15)),
      Text('Misc', style: TextStyle(fontSize: 15)),
      Text('Sports', style: TextStyle(fontSize: 15)),
      Text('Abstract', style: TextStyle(fontSize: 15)),
      Text('Colors', style: TextStyle(fontSize: 15)),
    ];
  }

  setFrame(
      {String fileName, bool noFrame = false, bool decorationImage = false}) {
    print("setting frame");
    if (fileName != null) {
      setState(() => selectedFrame = fileName);
      cards.setFrame(fileName);
    } else if (noFrame) {
      setState(() => selectedFrame = "");
      cards.setFrame(null);
    } else if (decorationImage) {
      setState(() => selectedFrame = "existing-art");
      cards.setFrame(null, cards.current.decorationImage.hasFrameDimension);
    }
  }

  Widget frameSelectable(fileName) {
    if (fileName == "no-frame") return noFrame();
    if (fileName == "existing-art") return decorationImage();
    return GestureDetector(
      onTap: () {
        setFrame(fileName: fileName);
        cards.current.setShouldDeleteOldDecortionImage();
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
        decoration:
            selectedFrame == fileName ? selectedBoxDecoration : BoxDecoration(),
        child: SizedBox(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              LayoutBuilder(
                builder: (_, constraints) {
                  if (firstBuild) {
                    firstBuild = false;
                    _listItemWidth ??= constraints.biggest.width;
                    initialNavigateToSelectedFrame();
                  }
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
              Image.asset(framesPath + fileName),
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
        setFrame(noFrame: true);
        SystemChrome.setEnabledSystemUIOverlays([]);
        cards.current.setShouldDeleteOldDecortionImage();
      },
      child: Container(
        decoration:
            selectedFrame == "" ? selectedBoxDecoration : BoxDecoration(),
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

  BoxDecoration get selectedBoxDecoration {
    return const BoxDecoration(
      border: Border.symmetric(
        horizontal: BorderSide(
          color: Colors.blue,
          width: 10,
        ),
        vertical: BorderSide(
          color: Colors.blue,
          width: 8,
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
        setFrame(decorationImage: true);
        cards.current.shouldDeleteOldDecoration = false;
        SystemChrome.setEnabledSystemUIOverlays([]);
      },
      child: Container(
        decoration: selectedFrame == "existing-art"
            ? selectedBoxDecoration
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

  void _handleCategoryChange(int frameCategoryIndex,
      {int frameIndex, bool centerFrame = false}) {
    var categories = getFrameCategories();
    frameCategoryIndex ??= 0;
    print("frameCategoryIndex: $frameCategoryIndex");
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
    if (frameIndex != null) {
      double offset = halfScreenWidth - _listItemWidth / 2;
      _scrollController.jumpTo(
          frameIndex * (_listItemWidth + 5) - (centerFrame ? offset : 0));
    }
  }

  void _handleCarouselSlider(index) {
    int frameIndex = categoryIndexToFrameIndex(index);
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
            },
            onPanStart: (_) =>
                _carouselController.nextPage(reasonIsController: false),
            child: Container(width: 65, height: 25),
          ),
        ),
      ],
    );
  }

  List<String> get getFrameList {
    List<String> result = [];
    frameFiles.forEach((categoryName, frames) {
      frames.forEach((frame) => result.add(frame));
    });
    return result;
  }

  int get _framesCount {
    return getFrameList.length;
  }

  List<int> get _frameCategoryCounts {
    return frameFiles.values.map((cat) => cat.length).toList();
  }

  List<String> get _frameCategories {
    return frameFiles.keys.toList();
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

  int categoryIndexToFrameIndex(int selectedCategoryIndex) {
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

  int pixelsToCategoryIndex(double pixels) {
    var frameIndex = _pixelsToFrameIndex(pixels);
    frameIndex += 2;
    return _frameIndexToCategoryIndex(frameIndex);
  }

  // prevents animating through all categories between first and last categories on the carousel
  void animateToPage(int frameCategoryIndex) {
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
    // First item should be no frame, and second is decoration image (user art combined with or without frame) if exists.
    return Center(
      child: Container(
        height: 140,
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            var pixels = notification.metrics.pixels;
            int frameCategoryIndex = pixelsToCategoryIndex(pixels);
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
                    return frameSelectable(getFrameList[frameIndex]);
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
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 0),
      ),
    );
  }

  int _getFrameIndex(String frameFileName) {
    return getFrameList.indexOf(frameFileName);
  }

  void initialNavigateToSelectedFrame() {
    if (!cards.current.hasFrame) return;
    int frameIndex = _getFrameIndex(selectedFrame);
    print("frameIndex $frameIndex");

    print("_listItemWidth: $_listItemWidth");
    double pixels = frameIndex * _listItemWidth + 5.0;
    print("pixels $pixels");
    int categoryIndex = pixelsToCategoryIndex(pixels);
    print("category index: $categoryIndex");
    Future.delayed(Duration(milliseconds: 500), () {
      _currentFrameCategoryIndex = categoryIndex;
      animateToPage(categoryIndex);
      _handleCategoryChange(categoryIndex,
          frameIndex: frameIndex, centerFrame: true);
    });
  }

  void _setFrameAndCategorySelection() {
    print("setframe and category selction");
    if (cards.current.isUsingDecorationImage)
      selectedFrame = "existing-art";
    else if (cards.current.framePath != null) {
      selectedFrame = PATH.basename(cards.current.framePath);
    }
  }

  void _insertIfExistingArtFrame() {
    if (cards.current.decorationImage != null)
      frameFiles["Birthday"].insert(1, "existing-art");
  }

  @override
  Widget build(context) {
    cards ??= Provider.of<KaraokeCards>(context, listen: false);
    currentActivity ??= Provider.of<CurrentActivity>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);
    soundController ??= Provider.of<SoundController>(context, listen: false);
    if (currentFrameCategories == null) {
      currentFrameCategories = getFrameCategories();
      _handleCategoryChange(0);
      _insertIfExistingArtFrame();
      _setFrameAndCategorySelection();
      halfScreenWidth = MediaQuery.of(context).size.width / 2;
    }

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
