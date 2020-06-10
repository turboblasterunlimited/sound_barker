import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/widgets/no_photos_button.dart';
import 'package:K9_Karaoke/widgets/picture_grid.dart';

import '../providers/pictures.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/interface_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';
import '../screens/select_song_and_picture_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = 'main-screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    var outlineColor = Theme.of(context).accentColor;

    final barks = Provider.of<Barks>(context, listen: false);
    final songs = Provider.of<Songs>(context, listen: false);
    final pictures = Provider.of<Pictures>(context, listen: true);
    final imageController =
        Provider.of<ImageController>(context, listen: false);

    void downloadEverything() async {
      await barks.retrieveAll();
      Picture mountedPicture = await pictures.retrieveAll();
      if (mountedPicture != null)
        await imageController.createDog(mountedPicture);
      await songs.retrieveAll();
    }

    if (barks.all.isEmpty && songs.all.isEmpty && pictures.all.isEmpty) {
      downloadEverything();
    }

    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
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
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RawMaterialButton(
                child: Image.asset("assets/images/replace_before_release.png"),
                shape: CircleBorder(),
                elevation: 2.0,
                // fillColor: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.pushNamed(
                      context, SelectSongAndPictureScreen.routeName);
                },
              ),
            ),
          ],
          leading: Padding(
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
        ),
      ),
      drawer: AppDrawer(),
      endDrawer: PictureGrid(),
      body: Builder(
        builder: (ctx) => Container(
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Stack(
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
                                child: SingingImage(visibilityKey: "mainScreen"),
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
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  child: InterfaceSelector(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
