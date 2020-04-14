import 'package:flutter/material.dart';

import './bark_select_screen.dart';

class SongSelectScreen extends StatefulWidget {
  final songFamilyName;
  final songCategoryName;
  final allSongs;
  SongSelectScreen(this.songFamilyName, this.songCategoryName, this.allSongs);

  @override
  _SongSelectScreenState createState() => _SongSelectScreenState();
}

class _SongSelectScreenState extends State<SongSelectScreen> {
  final creatableSongs = [];
  List getCreatableSongs() {
    if (creatableSongs.length != 0) return creatableSongs;
    widget.allSongs.forEach((song) {
      if (song["song_family"] != widget.songFamilyName) return;
      if (song["category"] != widget.songCategoryName) return;
      creatableSongs.add(song);
    });
    return creatableSongs;
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
          widget.songFamilyName ?? "Misc.",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
        ),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: getCreatableSongs().length,
              itemBuilder: (ctx, i) =>
                  songCategoryCard(ctx, i, getCreatableSongs()[i]),
            ),
          ),
        ],
      ),
    );
  }
}

Widget songCategoryCard(ctx, i, song) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (context) => BarkSelectScreen(song, selectedBarkIds: []),
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
          title: Text(song["name"]),
          // Price of song
          trailing: Text("\$${song["price"]}"),
        ),
      ),
    ),
  );
}
