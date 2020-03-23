import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../providers/pictures.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/interface_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';

class MainScreen extends StatefulWidget {
  static const routeName = 'main-screen';
  // bool _showSpinner = false;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<AnimatedListState> _listKey =
        GlobalKey<AnimatedListState>();
    var outlineColor = Theme.of(context).accentColor;

    Barks barks = Provider.of<Barks>(context, listen: false);
    Songs songs = Provider.of<Songs>(context, listen: false);
    Pictures pictures = Provider.of<Pictures>(context, listen: false);

    void downloadEverything() {
      barks.retrieveAll();
      songs.retrieveAll();
      pictures.retrieveAll();
    }
    downloadEverything();


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(28.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).accentColor, size: 30),
          // backgroundColor: Theme.of(context).accentColor,
          backgroundColor: Colors.transparent,

          elevation: 0,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                OMIcons.cloudDownload,
              ),
              onPressed: () {
                downloadEverything();
              },
            ),
          ],
          title: Text(
            'Song Barker',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                shadows: [
                  Shadow(
                      // bottomLeft
                      offset: Offset(-1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // bottomRight
                      offset: Offset(1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // topRight
                      offset: Offset(1.5, 1.5),
                      color: outlineColor),
                  Shadow(
                      // topLeft
                      offset: Offset(-1.5, 1.5),
                      color: outlineColor),
                ],
                color: Colors.white),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          SingingImage(),

          // Flexible(
          //   flex: 2,
          //   child: Container(
          //     height: 400,
          //     child: SpinKitRing(
          //       color: Colors.blue,
          //       size: 100.0,
          //     ),
          //   ),
          // ),

          InterfaceSelector(),
        ],
      ),
    );
  }
}
