import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/widgets/card_creation_interface.dart';
import 'package:K9_Karaoke/widgets/card_progress_bar.dart';
import 'package:K9_Karaoke/widgets/spinner_half_screen_widget.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

  List get _playbackFiles {
    if (_canPlayRawBark)
      return [barks.tempRawBark.filePath, barks.tempRawBarkAmplitudes];
    else if (_canPlaySong)
      return [
        cards.currentCard.song.filePath,
        cards.currentCard.song.amplitudesPath
      ];
    else
      return null;
  }

  Future<void> _navigate() async {
    if (pictures.all.isEmpty)
      startCreateCard();
    else
      showMenu();
  }

  void startCreateCard() {
    currentActivity.startCreateCard(cards.newCurrentCard);
    Navigator.of(context).pushNamed(PhotoLibraryScreen.routeName);
  }

  void showMenu() {
    Navigator.of(context).pushNamed(MenuScreen.routeName);
  }

  @override
  void initState() {
    print("INITING MAIN SCREEN");
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _navigate();
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
    _canPlayRawBark
        ? imageController.mouthTrackSound(amplitudes: _playbackFiles[1])
        : imageController.mouthTrackSound(filePath: _playbackFiles[1]);
    await soundController.startPlayer(_playbackFiles[0], stopAll);
  }

  Widget mainAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't show the leading button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/logos/K9_logotype.png", width: 80),
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
                        hintText: cards.currentCardName,
                        counterText: "",
                        suffixIcon: cards.currentPictureIsStock
                            ? null
                            : Icon(LineAwesomeIcons.edit),
                        border: InputBorder.none),
                    onFieldSubmitted: (val) {
                      cards.setCurrentCardName(val);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  // This rename field works differently than on the coordinates setting page.
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
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
      ),
    );
  }

  bool get _canPlayRawBark {
    return currentActivity.isSpeak &&
        currentActivity.isOne &&
        barks.tempRawBark != null;
  }

  bool get _canPlaySong {
    return currentActivity.isSpeak && currentActivity.isSix;
  }

  void _handleTapPuppet() {
    print("Tapping webview!");
    if (canPlay()) _isPlaying ? stopAll() : startAll();
  }

  bool canPlay() {
    return !_isPlaying && _playbackFiles != null;
  }

  @override
  Widget build(BuildContext context) {
    print("Building main screen");

    bool everythingReady() {
      return imageController.isReady;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
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
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // Appbar and horizontal padding.
                Padding(
                  padding: EdgeInsets.only(top: 80, left: 22, right: 22),
                  // WebView
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleTapPuppet,
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Stack(
                        children: <Widget>[
                          SingingImage(),
                          Container(
                            child: canPlay()
                                ? Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        RawMaterialButton(
                                          elevation: 2.0,
                                          fillColor:
                                              Theme.of(context).primaryColor,
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                          shape: CircleBorder(),
                                        )
                                      ],
                                    ),
                                  )
                                : Center(),
                          ),
                          // add decoration canvas for currentActivity.isStyle
                        ],
                      ),
                    ),
                  ),
                ),
                if (cards.currentCard != null)
                  CardProgressBar(),
                if (!spinnerState.isLoading && cards.currentCard != null)
                  CardCreationInterface(),
                // Half screen spinner
                if (spinnerState.isLoading)
                  SpinnerHalfScreenWidget(),
              ],
            ),
            // Spinner
            if (!everythingReady())
              SpinnerWidget("Loading animation engine..."),
          ],
        ),
      ),
    );
  }
}
