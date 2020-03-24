import 'package:flutter/material.dart';

class SongSelectScreen extends StatefulWidget {
  final categoryName;
  final creatableSongs;
  SongSelectScreen(this.categoryName, this.creatableSongs);

  @override
  _SongSelectScreenState createState() => _SongSelectScreenState();
}

class _SongSelectScreenState extends State<SongSelectScreen> {
  // final allSongs =

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(28.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Song Barker',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 23, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Text("${widget.categoryName} Songs"),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: widget.creatableSongs.length,
            itemBuilder: (ctx, i) =>
                songCategoryCard(ctx, i, widget.creatableSongs[i]),
          ),
        ],
      ),
    );
  }
}

Widget songCategoryCard(ctx, i, categoryName) {
  return GestureDetector(
    // onTap: () {
    //   Navigator.push(
    //     ctx,
    //     MaterialPageRoute(
    //       builder: (context) => SongSelectorScreen(newPicture),
    //     ),
    //   );
    // },
    // child: Card(
    //   margin: EdgeInsets.symmetric(
    //     horizontal: 5,
    //     vertical: 3,
    //   ),
    //   child: Padding(
    //     padding: EdgeInsets.all(4),
    //     child: ListTile(
    //       leading: Icon(Icons.music_note, color: Colors.black, size: 40),
    //       title: Text(categoryName),
    //       // How many songs within this category
    //       trailing: Text("5"),
    //     ),
    //   ),
    // ),
  );
}
