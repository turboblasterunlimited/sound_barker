import 'dart:io';

import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/widgets/card_creation_interface.dart';
import 'package:K9_Karaoke/widgets/card_decorator_canvas.dart';
import 'package:K9_Karaoke/widgets/card_progress_bar.dart';
import 'package:K9_Karaoke/widgets/spinner_half_screen_widget.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
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

class _MainScreenState extends State<MainScreen> {
  User user;
  Barks barks;
  Songs songs;
  Pictures pictures;
  ImageController imageController;
  SpinnerState spinnerState;
  CurrentActivity currentActivity;
  KaraokeCards cards;
  SoundController soundController;
  bool _isPlaying = false;
  double screenWidth;
  // frame width in pixels / screenWidth in pixels
  double frameToScreenWidth;
  // Xs the frame padding in pixels
  double framePadding;

  List get _playbackFiles {
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

  Future<void> _navigate() async {
    // if (pictures.all.isEmpty)
    //   startCreateCard();
    // else
    Navigator.of(context).pushNamed(MenuScreen.routeName);
  }

  // void startCreateCard() {
  //   currentActivity.startCreateCard(cards.newCurrent);
  //   Navigator.of(context).pushNamed(PhotoLibraryScreen.routeName);
  // }

  @override
  void initState() {
    print("INITING MAIN SCREEN");
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
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

  @override
  void didChangeDependencies() {
    print("Did change Dep");
    super.didChangeDependencies();
    user = Provider.of<User>(context);
    barks = Provider.of<Barks>(context);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context);
    soundController = Provider.of<SoundController>(context);
    spinnerState = Provider.of<SpinnerState>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context);
  }

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     SystemChrome.restoreSystemUIOverlays();
  //     print("App State $state");
  //     print("restoring system ui overlays");
  //   } else {
  //     print("App State $state");
  //   }
  // }

  void stopAll() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      imageController.stopAnimation();
      soundController.stopPlayer();
    }
  }

  void startAll() async {
    print("start all");
    setState(() => _isPlaying = true);
    // Only songs have a .csv amplitude file, barks, messages and card/combined audio have a List of amplitudes in memory.
    soundController.startPlayer(_playbackFiles[0], stopAll);
    !_canPlayAudio && _canPlaySong
        ? imageController.mouthTrackSound(filePath: _playbackFiles[1])
        : imageController.mouthTrackSound(amplitudes: _playbackFiles[1]);
  }

  Widget mainAppBar() {
    var notificationPadding = MediaQuery.of(context).padding.top;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Don't show the leading button
      toolbarHeight: 80 - notificationPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/logos/K9_logotype.png",
              width: 100 - notificationPadding),
          // if (!showFrame)
          Expanded(
            child: Center(
              child: Container(
                width: 170,
                child: TextFormField(
                  enabled: !cards.currentPictureIsStock,
                  style: TextStyle(color: Colors.grey[600], fontSize: 20),
                  maxLength: 12,
                  textAlign: cards.currentPictureIsStock
                      ? TextAlign.center
                      : TextAlign.right,
                  decoration: InputDecoration(
                      hintText: cards.currentName,
                      counterText: "",
                      suffixIcon: cards.currentPictureIsStock
                          ? null
                          : Icon(LineAwesomeIcons.edit),
                      border: InputBorder.none),
                  onFieldSubmitted: (val) {
                    cards.setCurrentName(val);
                    FocusScope.of(context).unfocus();
                    SystemChrome.restoreSystemUIOverlays();
                  },
                ),
                // This rename field works differently than on the coordinates setting page.
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        // if (!showFrame)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: RawMaterialButton(
            child: Icon(
              Icons.menu,
              color: Colors.black,
              size: 30,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            onPressed: () {
              Navigator.of(context).pushNamed(MenuScreen.routeName);
            },
          ),
        ),
      ],
    );
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
            cards.current.hasSong);
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
    if (_playbackFiles != null) _isPlaying ? stopAll() : startAll();
  }

  bool get canPlay {
    return !_isPlaying && (_playbackFiles != null);
  }

  bool get _showDecorationCanvas {
    return currentActivity.isStyle &&
        (currentActivity.isTwo || currentActivity.isThree);
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

  @override
  Widget build(BuildContext context) {
    print("Building main screen");
    screenWidth ??= MediaQuery.of(context).size.width;
    frameToScreenWidth ??= screenWidth / 656;
    framePadding ??= frameToScreenWidth * 72;

    bool everythingReady() {
      return imageController.isReady;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: everythingReady() ? mainAppBar() : null,
      // Background image
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 70.0),
          // loading spinner or card creation
          child: Stack(
            children: <Widget>[
              // portrait, progress bar, interface, spinner
              Column(
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
                                          // left: constraints.biggest.height *
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
                                child: Image.asset(cards.current.framePath),
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
                                    return Positioned.fill(
                                      child: CardDecoratorCanvas(
                                        constraints.biggest.width,
                                        constraints.biggest.height,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            if (canPlay)
                              Positioned.fill(
                                child: Center(
                                  child: RawMaterialButton(
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

                  if (cards.current != null) CardProgressBar(),
                  if (!spinnerState.isLoading && cards.current != null)
                    CardCreationInterface(),
                  // Half screen spinner
                  if (spinnerState.isLoading) SpinnerHalfScreenWidget(),
                ],
              ),
              // Full screen Spinner
              if (!everythingReady())
                SpinnerWidget("Loading animation engine..."),
            ],
          ),
        ),
      ),
    );
  }
}
