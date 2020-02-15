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
            child: user.petCount() == 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: user.petCount(),
                          itemBuilder: (ctx, i) => new GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PetDetailsScreen.routeName);
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 100,
                                padding: EdgeInsets.only(left: 10, bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Visibility(
                                      visible: user.pets[i].imageUrl == null,
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  PetDetailsScreen.routeName);
                                        },
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                          size: 50,
                                        ),
                                        shape: CircleBorder(),
                                        elevation: 0,
                                        fillColor: Colors.white,
                                        padding: const EdgeInsets.all(15.0),
                                      ),
                                    ),
                                    Visibility(
                                      visible: user.pets[i].imageUrl != null,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user
                                                    .pets[i].imageUrl !=
                                                null
                                            ? NetworkImage(
                                                user.pets[i].imageUrl)
                                            : AssetImage(
                                                'assets/images/smallest_file.jpg'),
                                      ),
                                    ),
                                    Text(
                                      user.pets[i].name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: user.petCount(),
                          itemBuilder: (ctx, i) => new GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(PetDetailsScreen.routeName);
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 100,
                                padding: EdgeInsets.only(left: 10, bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Visibility(
                                      visible: user.pets[i].imageUrl == null,
                                      child: RawMaterialButton(
                                        onPressed: () {},
                                        child: Icon(
                                          Icons.pets,
                                          color: Colors.blue,
                                          size: 35.0,
                                        ),
                                        shape: CircleBorder(),
                                        elevation: 0,
                                        fillColor: Colors.white,
                                        padding: const EdgeInsets.all(20.0),
                                      ),
                                    ),
                                    Visibility(
                                      visible: user.pets[i].imageUrl != null,
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user
                                                    .pets[i].imageUrl !=
                                                null
                                            ? NetworkImage(
                                                user.pets[i].imageUrl)
                                            : AssetImage(
                                                'assets/images/smallest_file.jpg'),
                                      ),
                                    ),
                                    Text(
                                      user.pets[i].name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
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
