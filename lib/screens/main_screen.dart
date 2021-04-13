import 'dart:io';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_switcher.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
import 'package:K9_Karaoke/widgets/card_progress_bar.dart';
import 'package:K9_Karaoke/widgets/loading_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';

import '../providers/pictures.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/singing_image.dart';

// AKA CARD CREATION SCREEN
class MainScreen extends StatefulWidget {
  static const routeName = 'main-screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TheUser user;
  Barks barks;
  Songs songs;
  Pictures pictures;
  ImageController imageController;
  CurrentActivity currentActivity;
  KaraokeCards cards;
  SoundController soundController;
  double screenWidth;
  // frame width in pixels / screenWidth in pixels
  double frameToScreenWidth;
  // Xs the frame padding in pixels
  double framePadding;
  final textController = TextEditingController();
  List _playbackFiles;
  bool firstBuild = true;
  bool isPlaying = false;

  List _getPlaybackFiles() {
    if (_canPlayAudio) {
      print("_canPlayAudio");
      return [cards.current.audio.filePath, cards.current.audio.amplitudes];
    } else if (_canPlayRawBark) {
      print("_canPlayRawBark");
      return [barks.tempRawBark.filePath, barks.tempRawBarkAmplitudes];
    } else if (_canPlaySong) {
      print("_canPlaySong");
      return [cards.current.song.filePath, cards.current.song.amplitudesPath];
    } else if (_canPlayMessage) {
      print("_canPlayMessage");
      return [cards.current.message.path, cards.current.message.amps];
    } else
      print("can't play");
    return null;
  }

  @override
  void initState() {
    print("INITING MAIN SCREEN");
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    KeyboardVisibility.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: ${visible}');
      if (!visible) SystemChrome.setEnabledSystemUIOverlays([]);
    });
  }

  @override
  void dispose() {
    print("DISPOSING MAIN SCREEN");
    super.dispose();
  }

  _runOnce() {
    firstBuild = false;
    user = Provider.of<TheUser>(context);
    barks = Provider.of<Barks>(context);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context, listen: true);
    currentActivity.addListener(() {
      stopAll();
    });
  }

  void stopAll() {
    if (isPlaying) {
      imageController.stopAnimation();
      soundController.stopPlayer();
      setState(() => isPlaying = false);
    }
  }

  void startAll() async {
    print("start all");
    setState(() => isPlaying = true);
    // Only songs have a .csv amplitude file, barks, messages and card/combined audio have a List of amplitudes in memory.
    soundController.startPlayer(_playbackFiles[0], stopCallback: stopAll);
    !_canPlayAudio && _canPlaySong
        ? imageController.mouthTrackSound(filePath: _playbackFiles[1])
        : imageController.mouthTrackSound(amplitudes: _playbackFiles[1]);
  }

  bool get _canPlayRawBark {
    return currentActivity.isSpeak &&
        currentActivity.isOne &&
        barks.tempRawBark != null;
  }

  bool get _canPlaySong {
    return (currentActivity.isStyle &&
            currentActivity.isOne &&
            cards.current.onlySong()) ||
        (currentActivity.isSpeak &&
            currentActivity.isSix &&
            cards.current.hasASong);
  }

  bool get _canPlayMessage {
    return (currentActivity.isStyle &&
            currentActivity.isOne &&
            cards.current.onlyMessage()) ||
        (currentActivity.isSpeak &&
            currentActivity.isSeven &&
            (cards.current.message.exists));
  }

  bool get _canPlayAudio {
    return currentActivity.isStyle &&
        (currentActivity.isOne || currentActivity.isThree) &&
        (cards.current.audio.exists);
  }

  void _handleTapPuppet() {
    print("Tapping webview!");
    if (_playbackFiles != null) isPlaying ? stopAll() : startAll();
  }

  bool get showPlayButton {
    return !isPlaying && (_playbackFiles != null);
  }

  bool get _showDecorationCanvas {
    return currentActivity.isStyle &&
        (currentActivity.isTwo ||
            currentActivity.isThree && cards.current.hasDecoration);
  }

  bool get showFrame {
    return currentActivity.isStyle && cards.hasFrame;
  }

  bool get _showDecorationImage {
    return currentActivity.isStyle &&
        cards.current.decorationImage != null &&
        !cards.current.shouldDeleteOldDecoration;
  }

  bool get _useFramePadding {
    return currentActivity.isStyle && cards.current.hasFrameDimension;
  }

  bool get isDecorationScreen {
    return currentActivity.isStyle && currentActivity.isTwo;
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) _runOnce();

    print("Building main screen");
    screenWidth ??= MediaQuery.of(context).size.width;
    frameToScreenWidth ??= screenWidth / 656;
    framePadding ??= frameToScreenWidth * 72;
    textController.text = cards.currentName;
    _playbackFiles = _getPlaybackFiles();

    bool everythingReady() {
      return imageController.isReady;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: everythingReady() ? CustomAppBar() : null,
      // Background image
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),

        // loading spinner or card creation
        child: Stack(
          children: <Widget>[
            // portrait, progress bar, interface, spinner
            Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Column(
                children: <Widget>[
                  // frame and portrait
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _handleTapPuppet,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            SizedBox(
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Padding(
                                  // to shrink portrait to accomodate card frame
                                  padding: _useFramePadding
                                      ? EdgeInsets.only(
                                          // left: constraints.biPositioned(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)ggest.height *
                                          //     (72 / 778),
                                          top: constraints.biggest.height *
                                              (72 / 778),
                                          bottom: constraints.biggest.height *
                                              (194 / 778))
                                      : EdgeInsets.all(1),
                                  child: SingingImage(),
                                );
                              }),
                            ),
                            if (showFrame)
                              AspectRatio(
                                aspectRatio: 656 / 778,
                                child: FittedBox(
                                  child: Image.asset(cards.current.framePath),
                                ),
                              ),
                            if (_showDecorationImage)
                              AspectRatio(
                                aspectRatio: cards.current.decorationImage
                                        .hasFrameDimension
                                    ? 656 / 778
                                    : 1,
                                child: Image.file(
                                  File(cards.current.decorationImage.filePath),
                                ),
                              ),
                            if (_showDecorationCanvas && !_showDecorationImage)
                              IgnorePointer(
                                ignoring: currentActivity.isThree,
                                child: AspectRatio(
                                  aspectRatio:
                                      cards.current.hasFrame ? 656 / 778 : 1,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: CardDecoratorCanvas(
                                        constraints.biggest.width,
                                        constraints.biggest.height,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            if (showPlayButton)
                              Positioned.fill(
                                child: Center(
                                  child: RawMaterialButton(
                                    onPressed: () {},
                                    elevation: 2.0,
                                    fillColor: Theme.of(context).primaryColor,
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                    shape: CircleBorder(),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (cards.current != null &&
                      !isDecorationScreen &&
                      !cards.current.isSaved)
                    CardProgressBar(),
                  if (cards.current != null)
                    Padding(
                      padding:
                          EdgeInsets.only(top: isDecorationScreen ? 0 : 10.0),
                      child: AnimatedSize(
                          duration: Duration(milliseconds: 400),
                          vsync: this,
                          child: InterfaceSwitcher()),
                    ),
                ],
              ),
            ),
            // Full screen Spinner
            if (!everythingReady()) LoadingScreenWidget("Loading..."),
          ],
        ),
      ),
    );
  }
}
