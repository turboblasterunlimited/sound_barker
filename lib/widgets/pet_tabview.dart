import 'package:flutter/material.dart';

import '../widgets/song_list.dart';

import '../widgets/bark_list.dart';

class PetTabview extends StatelessWidget {
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Material(
              color: Theme.of(context).accentColor,
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.mic), text: "SOUNDS"),
                  Tab(icon: Icon(Icons.library_music), text: "SONGS"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BarkList(),
                  SongList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
