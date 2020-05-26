import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/tab_list_scroll_controller.dart';

import 'package:song_barker/screens/song_category_select_screen.dart';
import '../providers/sound_controller.dart';
import 'package:song_barker/widgets/song_playback_card.dart';
import '../providers/songs.dart';
import '../providers/spinner_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SongList extends StatefulWidget {
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
//
  Widget build(BuildContext context) {
    // print("song list building");
    final songs = Provider.of<Songs>(context, listen: false);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);

    return Column(
      children: <Widget>[
        RawMaterialButton(
          onPressed: spinnerState.songLoading
              ? null
              : () {
                  Navigator.pushNamed(
                      context, SongCategorySelectScreen.routeName);
                },
          child: spinnerState.songLoading
              ? SpinKitWave(
                  color: Colors.white,
                  size: 20,
                )
              : Text(
                  "TAP TO CREATE A SONG",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          elevation: 2.0,
          fillColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
        ),
        Expanded(
          child: AnimatedList(
            controller:
                Provider.of<TabListScrollController>(context, listen: false)
                    .scrollController,
            key: songs.listKey,
            initialItemCount: songs.all.length,
            padding: const EdgeInsets.all(0),
            itemBuilder: (ctx, i, Animation<double> animation) =>
                SongPlaybackCard(
                    i, songs.all[i], songs, soundController, animation),
          ),
        ),
      ],
    );
  }
}
