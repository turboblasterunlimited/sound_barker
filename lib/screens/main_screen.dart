import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/widgets/picture_grid.dart';

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
    final pictures = Provider.of<Pictures>(context, listen: false);

    void downloadEverything() async {
      await barks.retrieveAll();
      await songs.retrieveAll();
      await pictures.retrieveAll();
    }

    if (barks.all.isEmpty && songs.all.isEmpty && pictures.all.isEmpty) {
      downloadEverything();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
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
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 20,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Theme.of(context).accentColor,
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
                size: 20,
              ),
              shape: CircleBorder(),
              elevation: 2.0,
              fillColor: Theme.of(context).accentColor,
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
      endDrawer: PictureGrid(),
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              child: SingingImage(),
            ),
            Positioned(
              child: Align(
                child: InterfaceSelector(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
