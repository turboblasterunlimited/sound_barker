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
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';
import 'authentication_screen.dart';

class MainScreen extends StatefulWidget {
  // routeName seems to be '/' in some cases.
  static const routeName = 'main-screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  User user;
  Barks barks;
  Songs songs;
  Pictures pictures;
  ImageController imageController;
  SpinnerState spinnerState;
  CurrentActivity currentActivity;
  bool everythingDownloaded = false;
  KaraokeCards cards;
  KaraokeCard card;

  bool noAssets() {
    return barks.all.isEmpty && songs.all.isEmpty && pictures.all.isEmpty;
  }

  Future<void> signInCallback() async {
    if (noAssets()) await downloadEverything();
    setState(() => everythingDownloaded = true);
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

  void signInIfNeeded(context) {
    print("sign in if needed screen");
    print("user is signed in: ${user.isSignedIn()}");
    if (user.isSignedIn()) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AuthenticationScreen(signInCallback)));
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
    await songs.retrieveCreatableSongsData();
    await barks.retrieveAll();
    await songs.retrieveAll();
    await pictures.retrieveAll();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    user = Provider.of<User>(context);
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context);
    spinnerState = Provider.of<SpinnerState>(context);
    currentActivity = Provider.of<CurrentActivity>(context);
    cards = Provider.of<KaraokeCards>(context);

    Future.delayed(Duration.zero, () {
      signInIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    card = cards.currentCard;
    
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Don't show the leading button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/K9_logotype.png", width: 80),
              Expanded(
                child: Center(
                  child: Container(
                    width: 170,
                    // This rename field works differently than on the coordinates setting page.
                    child: TextFormField(
                      initialValue: card?.picture?.name ?? "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 20),
                      maxLength: 12,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                          counterText: "",
                          suffixIcon: Icon(LineAwesomeIcons.edit),
                          border: InputBorder.none),
                      // onChanged: (val) {

                      // },
                      onFieldSubmitted: (val) {
                        card?.picture?.setName(val);
                        FocusScope.of(context).unfocus();
                      },
                    ),
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
                // fillColor: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(MenuScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(),
      body: Builder(
        builder: (ctx) => Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: (details) {
                      return null;
                      // Scaffold.of(context).openEndDrawer();
                    },
                    onHorizontalDragStart: (details) {
                      Scaffold.of(ctx).openEndDrawer();
                    },
                    onTap: () {
                      print("Tapping webview!");
                      Scaffold.of(ctx).openEndDrawer();
                    },
                    // WebView
                    child: IgnorePointer(
                      ignoring: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Stack(
                            children: <Widget>[
                              SingingImage(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: cards.currentCard != null,
                    child: CardProgressBar(),
                  ),
                  Visibility(
                    visible: cards.currentCard != null,
                    child: CardCreationInterface(),
                  ),
                ],
              ),
              Visibility(
                visible: !imageController.isReady,
                child: SpinnerWidget('Loading...'),
              ),
              Visibility(
                visible: !everythingDownloaded,
                child: SpinnerWidget('Downloading content...'),
              ),
              Visibility(
                visible: !user.isSignedIn(),
                child: SpinnerWidget('Main screen spinner...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
