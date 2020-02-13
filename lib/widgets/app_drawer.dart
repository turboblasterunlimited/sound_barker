import 'package:flutter/material.dart';

import '../screens/barks_screen.dart';
import '../screens/pet_details_screen.dart';
import '../screens/all_songs_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Menu'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.shop),
              title: Text('Shop'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              }),
          Divider(),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Pets and Barks'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(BarksScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.library_music),
              title: Text('All Songs'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(AllSongsScreen.routeName);
              }),
        ],
      ),
    );
  }
}
