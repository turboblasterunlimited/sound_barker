import 'package:flutter/material.dart';

import '../widgets/song_list.dart';
import '../widgets/bark_list.dart';
import '../widgets/picture_grid.dart';
import '../widgets/greeting_card_grid.dart';

class InterfaceSelector extends StatelessWidget {
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
            height: 500,
            color: Theme.of(context).primaryColor,
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: <Widget>[
                  Material(
                    color: Theme.of(context).accentColor,
                    child: TabBar(
                      tabs: [
                        Tab(text: "SOUNDS"),
                        Tab(text: "SONGS"),
                        Tab(text: "IMAGES"),
                        Tab(text: "CARDS"),

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
                        GreetingCardGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
