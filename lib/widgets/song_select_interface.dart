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
  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);
    print("song count: ${songs.all.length}");
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {},
                child: Text("Song Library",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).backgroundColor,
                        fontSize: 16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
              Padding(padding: EdgeInsets.all(10)),
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
                    : Text("Song Store",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        )),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
            ],
          ),
          Expanded(
            child: AnimatedList(
              key: songs.listKey,
              initialItemCount: songs.all.length,
              padding: const EdgeInsets.all(0),
              itemBuilder: (ctx, i, Animation<double> animation) =>
                  SongPlaybackCard(
                      i, songs.all[i], songs, soundController, animation),
            ),
          ),
        ],
      ),
    );
  }
}
