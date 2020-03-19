import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import 'package:song_barker/widgets/song_playback_card.dart';
import '../providers/songs.dart';
import 'song_select_card.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List<Map> availableSongs = [
    {"name": "Happy Birthday", "price": 1, "id": 1},
    {"name": "Darth Vader", "price": 2, "id": 2}
  ];

  void showSongsToCreateDialog(context) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Song'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: availableSongs.length,
              itemBuilder: (ctx, i) =>
                  SongSelectCard(i, availableSongs[i], availableSongs[i]["id"]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Songs songs = Provider.of<Songs>(context, listen: false);
    SoundController soundController = Provider.of<SoundController>(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RawMaterialButton(
            onPressed: () => showSongsToCreateDialog(context),
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
