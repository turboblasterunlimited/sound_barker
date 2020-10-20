import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/spinner_state.dart';

// cardCreationSubstep.isFive
class SongArrangementSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Building song arrangement selector");
    final spinnerState = Provider.of<SpinnerState>(context, listen: false);
    final cards = Provider.of<KaraokeCards>(context, listen: false);
    final songFormula = cards.current.songFormula;
    print("song formula ids ${songFormula.ids}");
    final currentActivity =
        Provider.of<CurrentActivity>(context, listen: false);
    final Songs songs = Provider.of<Songs>(context, listen: false);

    void _createSong(int songFormulaId) async {
      spinnerState.startLoading("Creating your song!..");
      var songData =
          await RestAPI.createSong(cards.current.barkIds, songFormulaId);
      Song song = Song();
      await song.setSongData(songData);
      await song.downloadAndCombineSong();
      print("ADDING SONG");
      songs.addSong(song);
      cards.setCurrentSong(song);
      currentActivity.setNextSubStep();
      spinnerState.stopLoading();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InterfaceTitleNav("CHOOSE A STYLE",
            titleSize: 20, backCallback: currentActivity.setPreviousSubStep),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RawMaterialButton(
                  constraints:
                      const BoxConstraints(minWidth: 70.0, minHeight: 36.0),
                  onPressed: () =>
                      _createSong(songFormula.arrangement["harmonized"]),
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 22.0),
                ),
                Padding(padding: EdgeInsets.all(5)),
                RawMaterialButton(
                  constraints:
                      const BoxConstraints(minWidth: 60.0, minHeight: 36.0),
                  onPressed: () =>
                      _createSong(songFormula.arrangement["pitched"]),
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 13, horizontal: 22.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
