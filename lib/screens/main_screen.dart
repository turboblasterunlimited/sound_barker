import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/picture_menu_screen.dart';
import 'package:K9_Karaoke/widgets/card_creation_interface.dart';
import 'package:K9_Karaoke/widgets/card_progress_bar.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
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
  bool everythingDownloaded = true;
  KaraokeCards cards;

  bool noAssets() {
    return barks.all.isEmpty && songs.all.isEmpty && pictures.all.isEmpty;
  }

  Future<void> _firstThing() async {
    // download files
    user.setLoadFilesTrue();
    if (noAssets()) {
      setState(() => everythingDownloaded = false);
      await downloadEverything();
      setState(() => everythingDownloaded = true);
    }
    // Navigate
    if (pictures.all.isEmpty)
      startCreateCard();
    else
      showMenu();
  }

  void startCreateCard() {
    currentActivity.startCreateCard(cards.newCurrentCard);
    Navigator.of(context).pushNamed(PictureMenuScreen.routeName);
  }

  void showMenu() {
    Navigator.of(context).pushNamed(MenuScreen.routeName);
  }

  @override
  void initState() {
    print("INITING MAIN SCREEN");
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    print("DISPOSING MAIN SCREEN");
    super.dispose();
  }

  Future<void> downloadEverything() async {
    await pictures.retrieveAll();
    // need creatableSongData to get songIds
    await songs.retrieveCreatableSongsData();
    await barks.retrieveAll();
    await songs.retrieveAll();
  }

  void didChangeDependencies() {
    print("Did change Dep");
    super.didChangeDependencies();
    user = Provider.of<User>(context);
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context);
    spinnerState = Provider.of<SpinnerState>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context);
    if (!user.filesLoaded) _firstThing();
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
                // child: Consumer<KaraokeCards>(
                //   builder: (_, daCards, ch) {
                //     print("rebuilding consumer");
                //     print("current card name: ${daCards.currentCardName}");
                //     String _pictureName = daCards.currentCardName;
                child: Container(
                  width: 170,
                  child: TextFormField(
                    style: TextStyle(color: Colors.grey[600], fontSize: 20),
                    maxLength: 12,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                        hintText: cards.currentCardName,
                        counterText: "",
                        suffixIcon: Icon(LineAwesomeIcons.edit),
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

  @override
  Widget build(BuildContext context) {
    String loadingMessage() {
      if (!everythingDownloaded) {
        return 'Getting your stuff!...';
      } else if (!imageController.isReady) {
        return 'Loading animation engine...';
      }
      return "Loading...";
    }

    bool everythingReady() {
      return imageController.isReady && everythingDownloaded;
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
                    onTap: () {
                      // used to play and stop
                      print("Tapping webview!");
                    },
                    child: IgnorePointer(
                      ignoring: true,
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Stack(
                          children: <Widget>[
                            SingingImage(),
                            // add decoration canvas for currentActivity.isStyle
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (cards.currentCard != null)
                  CardProgressBar(),
                if (cards.currentCard != null)
                  CardCreationInterface(),
              ],
            ),

            // Spinner
            if (!everythingReady())
              SpinnerWidget(loadingMessage()),
          ],
        ),
      ),
    );
  }
}
