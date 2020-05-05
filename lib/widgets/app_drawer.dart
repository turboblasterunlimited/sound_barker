import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/functions/app_storage_path.dart';

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
                  backgroundColor: Theme.of(context).accentColor,
                  title: Text('Song Barker'),
                  automaticallyImplyLeading: false,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.mic),
                  title: Text('Recording Booth'),
                  onTap: () {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(Navigator.defaultRouteName),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.portrait),
                  title: Text('Account'),
                  onTap: () {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(Navigator.defaultRouteName),
                    );
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
