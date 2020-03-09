import 'package:flutter/material.dart';

import '../widgets/song_list.dart';
import '../widgets/bark_list.dart';
import '../widgets/picture_grid.dart';

class InterfaceSelector extends StatelessWidget {
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Material(
              color: Theme.of(context).accentColor,
              child: TabBar(
                tabs: [
                  Tab(text: "SOUNDS"),
                  Tab(text: "SONGS"),
                  Tab(text: "IMAGES"),
                  // Tab(icon: Icon(Icons.mic), text: "SOUNDS"),
                  // Tab(icon: Icon(Icons.library_music), text: "SONGS"),
                  // Tab(icon: Icon(Icons.camera_alt), text: "IMAGES"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BarkList(),
                  SongList(),
                  PictureGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}