import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

import './song_select_screen.dart';
import '../services/rest_api.dart';

List<String> songCategories = [
  "Classical",
  "Jazz",
  "Folk",
  "Rock",
  "Kids",
  "National",
  "Holiday"
];

class SongCategorySelectScreen extends StatefulWidget {
  static const routeName = 'song-category-screen';

  @override
  _SongCategorySelectScreenState createState() =>
      _SongCategorySelectScreenState();
}

class _SongCategorySelectScreenState extends State<SongCategorySelectScreen> {
  @override
  Widget build(BuildContext context) {
    Future<Map> collectCreatableSongsByCategory() async {
      String serverResponse =
          await RestAPI.retrieveAllCreatableSongsFromServer();
      List creatableSongs = json.decode(serverResponse);
      Map<String, List<Map>> creatableSongsByCategory = {};
      creatableSongs.forEach((song) {
        if (!creatableSongsByCategory.containsKey(song["category"])) {
          creatableSongsByCategory[song["category"]] = [];
        }
        creatableSongsByCategory[song["category"]].add(song);
      });
      return creatableSongsByCategory;
    }

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Song Categories',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Center(
          //   child: Padding(
          //     padding: const EdgeInsets.all(20.0),
          //     child: Text(
          //       "Song Categories",
          //       style: TextStyle(fontSize: 30),
          //     ),
          //   ),
          // ),
          Expanded(
            child: FutureBuilder(
                future: collectCreatableSongsByCategory(),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.waiting &&
                      projectSnap.hasData == false) {
                    print('project snapshot data is: ${projectSnap.data}');
                    return Center(child: SpinKitWave(color: Theme.of(context).primaryColor, size: 80,));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: projectSnap.data.length,
                    itemBuilder: (ctx, i) => songCategoryCard(
                        ctx,
                        i,
                        projectSnap.data.keys.toList()[i],
                        projectSnap.data.values.toList()[i]),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

Widget songCategoryCard(ctx, int i, String categoryName, List songs) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (context) => SongSelectScreen(categoryName, songs),
        ),
      );
    },
    child: Card(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: ListTile(
          leading: Icon(Icons.music_note, color: Colors.black, size: 40),
          title: Text(categoryName),
          // How many songs within this category
          trailing: Text(songs.length.toString()),
        ),
      ),
    ),
  );
}
