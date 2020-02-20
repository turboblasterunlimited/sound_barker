import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/song_playback_card.dart';

import '../providers/songs.dart';
import '../widgets/app_drawer.dart';

class AllSongsScreen extends StatelessWidget {
  static const routeName = 'all-songs';

  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Center(
            child: Text(
              "All Songs",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: songs.all.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: songs.all[i],
                child: SongPlaybackCard(i, songs.all[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
