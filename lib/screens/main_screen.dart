import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/picture_menu_screen.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';

import '../providers/pictures.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/interface_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';
import 'authentication_screen.dart';

class MainScreen extends StatefulWidget {
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
    currentActivity.startCreateCard();
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
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future<void> downloadEverything() async {
    await songs.retrieveCreatableSongsData();
    await barks.retrieveAll();
    Picture mountedPicture = await pictures.retrieveAll();
    if (mountedPicture != null) await imageController.createDog(mountedPicture);
    await songs.retrieveAll();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context, listen: false);
    spinnerState = Provider.of<SpinnerState>(context);
    currentActivity = Provider.of<CurrentActivity>(context);

    Future.delayed(Duration.zero, () {
      signInIfNeeded(context);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).primaryColor, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Icon(LineAwesomeIcons.paw),
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
                              Visibility(
                                maintainState: true,
                                visible: pictures.all.isNotEmpty,
                                child: SingingImage(),
                              ),
                              // Visibility(
                              //   maintainState: true,
                              //   visible: pictures.all.isEmpty,
                              //   child: NoPhotosButton(),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  InterfaceSelector(),
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
