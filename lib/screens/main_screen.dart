import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/barks.dart';
import '../providers/songs.dart';
import '../widgets/interface_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';

class MainScreen extends StatefulWidget {
  static const routeName = 'main-screen';
  bool _showSpinner = false;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    Barks barks = Provider.of<Barks>(context, listen: false);
    Songs songs = Provider.of<Songs>(context, listen: false);

    Future downloadEverything() async {
      await songs.retrieveAllSongs();
      await barks.retrieveAllBarks();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.cloud_download,
            ),
            onPressed: () async {
              setState(() => widget._showSpinner = true);
              await downloadEverything();
              setState(() => widget._showSpinner = false);
            },
          ),
        ],
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          SingingImage(),
          Visibility(
            visible: widget._showSpinner,
            child: Flexible(
              flex: 2,
              child: Container(
                height: 400,
                child: SpinKitRing(
                  color: Colors.blue,
                  size: 100.0,
                ),
              ),
            ),
          ),
          Visibility(visible: !widget._showSpinner, child: InterfaceSelector()),
        ],
      ),
    );
  }
}
