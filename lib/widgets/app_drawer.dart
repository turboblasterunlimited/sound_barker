import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../screens/record_barks_screen.dart';
import '../screens/pet_details_screen.dart';
import '../screens/all_songs_screen.dart';
import '../screens/make_songs_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
                        .pushReplacementNamed(RecordBarksScreen.routeName);
                  },
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.pets),
                    title: Text('Make Songs'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(MakeSongsScreen.routeName);
                    }),
                Divider(),
                ListTile(
                    leading: Icon(Icons.library_music),
                    title: Text('All Songs'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(AllSongsScreen.routeName);
                    }),
                Divider(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: user.petCount(),
                    itemBuilder: (ctx, i) => new GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(PetDetailsScreen.routeName);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  NetworkImage(user.pets[i].imageUrl),
                            ),
                            Center(
                              child: Text(
                                user.pets[i].name,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
