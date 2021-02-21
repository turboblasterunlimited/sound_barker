import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/songs.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/loading_half_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// cardCreationSubstep.isFive
class SongArrangementSelector extends StatefulWidget {
  @override
  _SongArrangementSelector createState() => _SongArrangementSelector();
}

class _SongArrangementSelector extends State<SongArrangementSelector> {
  KaraokeCards cards;
  var songFormula;
  Songs songs;
  CurrentActivity currentActivity;
  bool _isLoading = false;

  void _createSong(int songFormulaId) async {
    setState(() => _isLoading = true);
    var songData =
        await RestAPI.createSong(cards.current.barkIds, songFormulaId);
    if (songData["error"] != null) {
      setState(() => _isLoading = false);
      showError(context, songData["error"]);
      return null;
    }
    Song song = Song();
    await song.setSongData(songData);
    await song.downloadAndCombineSong();
    print("ADDING SONG");
    songs.addSong(song);
    cards.setCurrentSong(song);
    currentActivity.setNextSubStep();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    songFormula = cards.current.songFormula;
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    songs = Provider.of<Songs>(context, listen: false);

    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InterfaceTitleNav(title: "CHOOSE STYLE",
              titleSize: 20, backCallback: currentActivity.setPreviousSubStep),
          _isLoading
              ? LoadingHalfScreenWidget("Creating Song...")
              : SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 10,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          constraints: const BoxConstraints(
                              minWidth: 70.0, minHeight: 36.0),
                          onPressed: () => _createSong(
                              songFormula.arrangement["harmonized"]),
                          child: Text(
                            "Make my dog\nsound realistic",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
                          ),
                          elevation: 2.0,
                          fillColor: null,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 22.0),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        RawMaterialButton(
                          constraints: const BoxConstraints(
                              minWidth: 60.0, minHeight: 36.0),
                          onPressed: () =>
                              _createSong(songFormula.arrangement["pitched"]),
                          child: Text(
                            "Make my dog\nhit all the notes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3),
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
      ),
    );
  }
}
