import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/song.dart';

class AllSongsScreen extends StatelessWidget {
  static const routeName = 'all-songs';

  @override
  Widget build(BuildContext context) {
    // final song = Provider.of<Song>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: Center(

        //Gridview.builder for all songs.

      ),
    );
  }
}
