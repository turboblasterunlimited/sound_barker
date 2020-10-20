import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/creatable_song_select_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import 'package:K9_Karaoke/widgets/song_playback_card.dart';
import '../providers/songs.dart';
import '../providers/spinner_state.dart';

class SongSelectInterface extends StatefulWidget {
  @override
  _SongSelectInterfaceState createState() => _SongSelectInterfaceState();
}

class _SongSelectInterfaceState extends State<SongSelectInterface>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  var tween;
  final _listKey = GlobalKey<AnimatedListState>();
  Songs songs;
  KaraokeCard card;
  CurrentActivity currentActivity;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    tween = Tween(begin: -60.0, end: -40.0).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _skipCallback() {
    card.noSongNoFormula();
    currentActivity.setCardCreationStep(
        CardCreationSteps.speak, CardCreationSubSteps.seven);
  }

  void _backCallback() {
    if (card.picture.isStock)
      Navigator.of(context).pushNamed(PhotoLibraryScreen.routeName);
    else
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SetPictureCoordinatesScreen(card.picture, editing: true),
        ),
      );
    currentActivity.setCardCreationStep(CardCreationSteps.snap);
  }

  Widget build(BuildContext context) {
    songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    final spinnerState = Provider.of<SpinnerState>(context, listen: true);
    card = Provider.of<KaraokeCards>(context, listen: false).current;
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InterfaceTitleNav("PICK A SONG",
            skipCallback: _skipCallback, backCallback: _backCallback),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed: () {},
              child: Text(
                "My Songs",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
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
                  child: Text("New Song",
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                ),
                if (songs.all.isEmpty)
                  AnimatedBuilder(
                      animation: animationController,
                      builder: (BuildContext context, Widget child) {
                        return Positioned(
                          bottom: tween.value,
                          left: 0,
                          right: 0,
                          child: Icon(Icons.arrow_upward,
                              size: 50, color: Theme.of(context).primaryColor),
                        );
                      }),
              ],
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
                      "You have no songs.\nTap 'New Song'.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: songs.all.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (ctx, i, Animation<double> animation) =>
                      SongPlaybackCard(
                    i,
                    songs.all[i],
                    songs,
                    soundController,
                    animation,
                  ),
                ),
        ),
      ],
    );
  }
}
