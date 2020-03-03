import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/main_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text('Song Barker'),
                  automaticallyImplyLeading: false,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Recording Booth'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(MainScreen.routeName);
                  },
                ),
                Divider(),
                // ListTile(
                //     leading: Icon(Icons.pets),
                //     title: Text('Make Songs'),
                //     onTap: () {
                //       Navigator.of(context)
                //           .pushReplacementNamed(MakeSongsScreen.routeName);
                //     }),
                // Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
