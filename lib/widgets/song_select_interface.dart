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

class _SongSelectInterfaceState extends State<SongSelectInterface> with SingleTickerProviderStateMixin {
  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);
    final card = Provider.of<KaraokeCards>(context, listen: false).current;
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);
    AnimationController animationController;

    initState() {
      super.initState();
      animationController = AnimationController();
    }

    void dispose() {            
       animationController.dispose();            
       super.dispose();            
      }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  child: Text("My Songs",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3),
                  ),
                  elevation: 2.0,
                  fillColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                ),
                Padding(padding: EdgeInsets.only(left: 16)),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    RawMaterialButton(
                      onPressed: spinnerState.isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                  context, CreatableSongSelectScreen.routeName);
                            },
                      child: Text("Make Song",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          )),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 3),
                      ),
                      elevation: 2.0,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 18),
                    ),
                    if (songs.all.isEmpty)
                      Positioned(
                        bottom: -40,
                        left: 0,
                        right: 0,
                        child: Icon(Icons.arrow_upward,
                            size: 50, color: Theme.of(context).primaryColor),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  card.noSongNoFormula();
                  currentActivity.setCardCreationStep(
                      CardCreationSteps.speak, CardCreationSubSteps.seven);
                },
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
        Padding(padding: EdgeInsets.only(top: 14)),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: songs.all.isEmpty
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Text(
                      "You have no songs.\nTap 'Make Song'.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : AnimatedList(
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
