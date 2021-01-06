import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/creatable_song_card.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import 'package:K9_Karaoke/widgets/song_playback_card.dart';
import '../providers/songs.dart';

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
  KaraokeCards cards;
  CurrentActivity currentActivity;
  bool showMySongs = false;
  CreatableSongs creatableSongs;
  KaraokeCard card;

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
    if (!card.picture.isStock)
      currentActivity.setCardCreationStep(CardCreationSteps.snap);
  }

  void _handleMySongsButton() {
    setState(() {
      showMySongs = true;
    });
  }

  void _handleNewSongButton() {
    setState(() {
      showMySongs = false;
    });
  }

  Widget build(BuildContext context) {
    songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    creatableSongs = Provider.of<CreatableSongs>(context, listen: false);
    card = cards.current;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        InterfaceTitleNav("CHOOSE SONG",
            skipCallback: _skipCallback, backCallback: _backCallback),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Stack(
              overflow: Overflow.visible,
              children: [
                RawMaterialButton(
                  onPressed: _handleNewSongButton,
                  child: Text("New Song",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: showMySongs
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        fontSize: 15,
                      )),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3),
                  ),
                  fillColor:
                      showMySongs ? null : Theme.of(context).primaryColor,
                  elevation: 2.0,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                ),
                if (showMySongs && songs.all.isEmpty)
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
                    },
                  ),
              ],
            ),
            Padding(padding: EdgeInsets.only(left: 16)),
            RawMaterialButton(
              onPressed: _handleMySongsButton,
              child: Text(
                "My Songs",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: showMySongs
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 2.0,
              fillColor: showMySongs ? Theme.of(context).primaryColor : null,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            ),
            Padding(padding: EdgeInsets.only(left: 16)),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Column(
                children: [
                  Icon(Icons.arrow_upward),
                  Text("No Song"),
                ],
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 14)),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: showMySongs
              ? songs.all.isEmpty
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          "You have no songs.\nCreate a New Song.",
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
                    )
              : ListView.builder(
                  padding: const EdgeInsets.only(right: 10),
                  itemCount: creatableSongs.all.length,
                  itemBuilder: (ctx, i) => CreatableSongCard(
                      creatableSongs.all[i],
                      soundController,
                      cards,
                      currentActivity),
                ),
        ),
      ],
    );
  }
}
