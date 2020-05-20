import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

import './song_family_select_screen.dart';
import '../services/rest_api.dart';

class SongCategorySelectScreen extends StatefulWidget {
  static const routeName = 'song-category-select-screen';
  
  @override
  _SongCategorySelectScreenState createState() =>
      _SongCategorySelectScreenState();
}

class _SongCategorySelectScreenState extends State<SongCategorySelectScreen> {
  List creatableSongs;
  Map<String, int> creatableSongsByCategory = {};


    Future<Map> collectCreatableSongsByCategory() async {
      if (creatableSongsByCategory.length != 0) return creatableSongsByCategory;
      print("building creatable songs");
      creatableSongs =
          await RestAPI.retrieveAllCreatableSongsFromServer();
      print("creatable songs retrieved: $creatableSongs");

      creatableSongs.forEach((song) {
        if (!creatableSongsByCategory.containsKey(song["category"])) {
          creatableSongsByCategory[song["category"]] = 1;
        } else {
          creatableSongsByCategory[song["category"]] += 1;
        }
      });
      print("done building: $creatableSongsByCategory");
      return creatableSongsByCategory;
    }

  @override
  Widget build(BuildContext context) {

    Widget songCategoryCard(
      ctx,
      int i,
      String categoryName,
      int numberOfSongFamilies,
    ) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (context) =>
                  SongFamilySelectScreen(categoryName, creatableSongs),
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
              title: Text(categoryName ?? "Misc."),
              // How many songs within this category
              trailing: Text(numberOfSongFamilies.toString()),
            ),
          ),
        ),
      );
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
                    return Center(
                        child: SpinKitWave(
                      color: Theme.of(context).primaryColor,
                      size: 80,
                    ));
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
