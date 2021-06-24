import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/cart_type_screen.dart';
import 'package:K9_Karaoke/screens/photo_library_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/widgets/creatable_song_card.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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
  CreatableSongs creatableSongs;
  KaraokeCard card;
  bool firstBuild = true;

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
    currentActivity.cardTypeNull();
    Navigator.of(context).pushNamed(CardTypeScreen.routeName);
  }

  Widget build(BuildContext context) {
    print("building song select interface");
    songs = Provider.of<Songs>(context);
    final soundController = Provider.of<SoundController>(context);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context);
    creatableSongs = Provider.of<CreatableSongs>(context, listen: false);
    card = cards.current;
    // goto Card type screen if no card type is selected, then come back.
    if (firstBuild && currentActivity.cardType == null) {
      print("TESTTESTTESTTESTTESTTESTTESTETSTETSTESTSELFJ!!!!!!!");
      setState(() => firstBuild = false);
      Future.delayed(
        Duration(seconds: 0),
        () => Navigator.of(context).pushNamed(CardTypeScreen.routeName),
      );
    }

    return currentActivity.cardType == null
        ? Center()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InterfaceTitleNav(
                  title: "SELECT SONG",
                  skipCallback: _skipCallback,
                  backCallback: _backCallback),
              /**
         * JMF 3/29/2021: Added header row
         */
              Row(children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1.0),
                    child: Text(
                      "    ",
                      style: TextStyle(
                        color: Colors.blue,
                        // decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "LISTEN TO BACKING TRACK",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            // decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ))),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: currentActivity.cardType == CardType.oldSong
                    ? songs.all.isEmpty
                        // NO SONG MESSAGE
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

                        // SELECT OLD SONG
                        : AnimatedList(
                            key: _listKey,
                            initialItemCount: songs.all.length,
                            padding: const EdgeInsets.all(0),
                            itemBuilder:
                                (ctx, i, Animation<double> animation) =>
                                    SongPlaybackCard(
                              i,
                              songs.all[i],
                              songs,
                              soundController,
                              animation,
                            ),
                          )

                    // CREATE NEW SONG
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
