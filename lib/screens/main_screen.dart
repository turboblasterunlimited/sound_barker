import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../providers/pictures.dart';
import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/interface_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';
import '../providers/image_controller.dart';

class MainScreen extends StatefulWidget {
  static const routeName = 'main-screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

    final barks = Provider.of<Barks>(context, listen: false);
    final songs = Provider.of<Songs>(context, listen: false);
    final pictures = Provider.of<Pictures>(context, listen: false);
    ImageController imageController =
        Provider.of<ImageController>(context, listen: false);

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
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).accentColor, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[],
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
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ),
          
        ),
      ),
      drawer: AppDrawer(),
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
