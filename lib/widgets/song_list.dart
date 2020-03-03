import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../providers/sound_controller.dart';
import 'package:song_barker/widgets/song_playback_card.dart';
import '../providers/songs.dart';
import 'creatable_song.dart';
import '../providers/barks.dart';
import 'bark_select_card.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  void selectBarksForSongDialog(context) async {
    Barks barks = Provider.of<Barks>(context, listen: false);
    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Bark'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          Visibility(
            visible: barks.all.length != 0,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: barks.all.length,
                itemBuilder: (ctx, i) => BarkSelectCard(i, barks.all[i]),
              ),
            ),
          ),
          Visibility(
            visible: barks.all.length > 0,
            child: Text("You have no barks recorded."),
          )
        ],
      ),
    );
  }

  void showSongsToCreateDialog(context) async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Song'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          Card(
            margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: FittedBox(
                      child: Text('\$1'),
                    ),
                  ),
                ),
                title: Text("Happy Birthday"),
                subtitle: Text('to you...'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    selectBarksForSongDialog(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Songs songs = Provider.of<Songs>(context);
    FlutterSound flutterSound =
        Provider.of<SoundController>(context).flutterSound;

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
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: songs.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: songs.all[i],
              child: SongPlaybackCard(i, songs.all[i], flutterSound),
            ),
          ),
        ),
      ],
    );
  }
}
