import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/providers/user.dart';
import 'package:K9_Karaoke/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/widgets/no_photos_button.dart';

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

  void signInIfNeeded(context) {
    print("sign in if needed screen");
    print("user is signed in: ${user.isSignedIn()}");
    if (user.isSignedIn()) return;
    Navigator.of(context).pushNamed(AuthenticationScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  void downloadEverything() async {
    await songs.retrieveCreatableSongsData();
    await barks.retrieveAll();
    Picture mountedPicture = await pictures.retrieveAll();
    if (mountedPicture != null) await imageController.createDog(mountedPicture);
    await songs.retrieveAll();
  }

  @override
  Widget build(BuildContext context) {
    var outlineColor = Theme.of(context).accentColor;
    user = Provider.of<User>(context);

    barks = Provider.of<Barks>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);
    pictures = Provider.of<Pictures>(context, listen: true);
    imageController = Provider.of<ImageController>(context, listen: false);
    spinnerState = Provider.of<SpinnerState>(context);

    // if (barks.all.isEmpty && songs.all.isEmpty && pictures.all.isEmpty) {
    //   downloadEverything();
    // }
    Future.delayed(Duration.zero, () => signInIfNeeded(context));
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).accentColor, size: 30),
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
                  color: Colors.white,
                  size: 30,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                // fillColor: Theme.of(context).accentColor,
                onPressed: () {
                  scaffoldKey.currentState.openDrawer();
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
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Stack(
                          children: <Widget>[
                            Visibility(
                              maintainState: true,
                              visible: pictures.all.isNotEmpty,
                              child: SingingImage(),
                            ),
                            Visibility(
                              maintainState: true,
                              visible: pictures.all.isEmpty,
                              child: NoPhotosButton(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InterfaceSelector(),
                ],
              ),
              Visibility(
                visible: !Provider.of<User>(context).isSignedIn(),
                child: SpinnerWidget('main screen spinner...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
