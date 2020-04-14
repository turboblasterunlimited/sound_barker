import 'package:flutter/material.dart';

import './song_select_screen.dart';

class SongFamilySelectScreen extends StatefulWidget {
  static const routeName = 'song-family-select-screen';
  final songCategoryName;
  final creatableSongs;
  SongFamilySelectScreen(this.songCategoryName, this.creatableSongs);

  @override
  _SongFamilySelectScreenState createState() => _SongFamilySelectScreenState();
}

class _SongFamilySelectScreenState extends State<SongFamilySelectScreen> {
  Map<String, int> creatableSongsByFamily = {};
  Map<String, int> getCreatableSongsByFamily() {
    if (creatableSongsByFamily.length != 0) return creatableSongsByFamily;
    widget.creatableSongs.forEach((song) {
      if (song["category"] != widget.songCategoryName) return;
      if (!creatableSongsByFamily.containsKey(song["song_family"])) {
        creatableSongsByFamily[song["song_family"]] = 1;
      } else {
        creatableSongsByFamily[song["song_family"]] += 1;
      }
    });
    return creatableSongsByFamily;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Songs',
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
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: getCreatableSongsByFamily().length,
              itemBuilder: (ctx, i) => songFamilyCard(
                  ctx,
                  i,
                  getCreatableSongsByFamily().keys.toList()[i],
                  widget.songCategoryName,
                  getCreatableSongsByFamily().values.toList()[i],
                  widget.creatableSongs),
            ),
          ),
        ],
      ),
    );
  }
}

Widget songFamilyCard(ctx, int i, String familyName, String songCategoryName,
    int songNumber, List creatableSongs) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (context) => SongSelectScreen(
              familyName, songCategoryName, creatableSongs),
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
          title: Text(familyName ?? "Misc."),
          // How many songs within this category
          trailing: Text(songNumber.toString()),
        ),
      ),
    ),
  );
}
