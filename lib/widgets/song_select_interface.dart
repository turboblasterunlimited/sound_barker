import 'package:K9_Karaoke/screens/song_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import 'package:K9_Karaoke/widgets/song_playback_card.dart';
import '../providers/songs.dart';
import '../providers/spinner_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SongSelectInterface extends StatefulWidget {
  @override
  _SongSelectInterfaceState createState() => _SongSelectInterfaceState();
}

class _SongSelectInterfaceState extends State<SongSelectInterface> {
//
  Widget build(BuildContext context) {
    // print("song list building");
    final songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
            ),
            RawMaterialButton(
              onPressed: spinnerState.songLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, SongStoreScreen.routeName);
                    },
              child: spinnerState.songLoading
                  ? SpinKitWave(
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      "Song Store",
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
          ],
        ),
        Visibility(
          visible: songs.all.isNotEmpty,
          child: Expanded(
            child: AnimatedList(
              key: songs.listKey,
              initialItemCount: songs.all.length,
              padding: const EdgeInsets.all(0),
              itemBuilder: (ctx, i, Animation<double> animation) =>
                  SongPlaybackCard(
                      i, songs.all[i], songs, soundController, animation),
            ),
          ),
        ),
      ],
    );
  }
}
