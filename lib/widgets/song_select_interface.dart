import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/creatable_song_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
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
    final card = Provider.of<KaraokeCards>(context, listen: false).current;
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              RawMaterialButton(
                onPressed: () {},
                child: Text("My Songs",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                onPressed: spinnerState.isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(
                            context, CreatableSongSelectScreen.routeName);
                      },
                child: spinnerState.isLoading
                    ? SpinKitWave(
                        color: Colors.white,
                        size: 20,
                      )
                    : Text("Make Song",
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
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  card.noSongNoFormula();
                  currentActivity.setCardCreationStep(
                      CardCreationSteps.speak, CardCreationSubSteps.seven);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: <Widget>[
                      Text('Skip', style: TextStyle(color: Colors.grey)),
                      Icon(
                        LineAwesomeIcons.angle_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
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
