import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import '../providers/spinner_state.dart';
// cardCreationSubstep.isFive
class SongArrangementSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Building song arrangement selector");
    final spinnerState = Provider.of<SpinnerState>(context, listen: false);
    final cards = Provider.of<KaraokeCards>(context, listen: false);
    final songFormula = cards.currentCard.songFormula;
    print("song formula ids ${songFormula.ids}");
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);
    final Songs songs = Provider.of<Songs>(context, listen: false);

    void _createSong(int songFormulaId) async {
      spinnerState.startLoading("Creating your song!..");
      var songData =
          await RestAPI.createSong(cards.currentCard.barkIds, songFormulaId);
      Song song = Song();
      await song.retrieveSong(songData);
      print("ADDING SONG");
      songs.addSong(song);
      cards.setCurrentCardSong(song);
      currentActivity.setNextSubStep();
      spinnerState.stopLoading();
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        currentActivity.setPreviousSubStep();
                      },
                      child: Row(children: <Widget>[
                        Icon(LineAwesomeIcons.angle_left),
                        Text('Back'),
                      ]),
                    ),
                    Center(
                      child: Text("CHOOSE A STYLE",
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.all(20),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () =>
                    _createSong(songFormula.arrangement["pitched"]),
                child: Text(
                  "Make my dog\nsound realistic",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor: null,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
              Padding(padding: EdgeInsets.all(10)),
              RawMaterialButton(
                onPressed: () =>
                    _createSong(songFormula.arrangement["harmonized"]),
                child: Text(
                  "Make my dog\nhit all the notes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
                ),
                elevation: 2.0,
                fillColor: null,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
              ),
            ],
          ),
        ]);
  }
}
