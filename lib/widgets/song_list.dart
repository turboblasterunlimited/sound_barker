import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:song_barker/screens/song_category_select_screen.dart';
import '../providers/sound_controller.dart';
import 'package:song_barker/widgets/song_playback_card.dart';
import '../providers/songs.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  Widget build(BuildContext context) {
    Songs songs = Provider.of<Songs>(context, listen: false);
    SoundController soundController = Provider.of<SoundController>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RawMaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, SongCategorySelectScreen.routeName);
            },
            child: Icon(
              Icons.add,
              color: Colors.black38,
              size: 40,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(15.0),
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: songs.listKey,
            initialItemCount: songs.all.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, i, Animation<double> animation) =>
                SongPlaybackCard(
                    i, songs.all[i], songs, soundController, animation),
          ),
        ),
      ],
    );
  }
}
