import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/screens/bark_select_screen.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import '../widgets/error_dialog.dart';
import '../providers/sound_controller.dart';

class CreatableSongCard extends StatefulWidget {
  final Map creatableSong;
  final SoundController soundController;
  final KaraokeCards cards;
  final CurrentActivity currentActivity;

  CreatableSongCard(this.creatableSong, this.soundController, this.cards,
      this.currentActivity);

  @override
  _CreatableSongCardState createState() => _CreatableSongCardState();
}

class _CreatableSongCardState extends State<CreatableSongCard> {
  bool isPlaying = false;

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  Function stopPlayerCallBack() {
    return () {
      widget.soundController.stopPlayer();
      if (mounted) setState(() => isPlaying = false);
    };
  }

  void playSong() async {
    try {
      await widget.soundController.startPlayer(
          "https://storage.googleapis.com/song_barker_sequences/" +
              widget.creatableSong["backing_track_bucket_fp"],
          stopPlayerCallBack());
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void _selectSongFormula() {
    widget.cards.setCurrentCardSongFormulaId(widget.creatableSong["id"]);
    widget.currentActivity.setCardCreationStep(CardCreationSteps.speak);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Playback button
        IconButton(
          color: Colors.blue,
          onPressed: () {
            if (isPlaying) {
              widget.soundController.stopPlayer();
            } else {
              playSong();
              Future.delayed(Duration(milliseconds: 50), () {
                setState(() => isPlaying = true);
              });
            }
          },
          icon: isPlaying
              ? Icon(Icons.stop, color: Theme.of(context).errorColor, size: 30)
              : Icon(Icons.play_arrow, color: Theme.of(context).primaryColor, size: 30),
        ),
        // Select song button
        Expanded(
          child: RawMaterialButton(
            onPressed: _selectSongFormula,
            child: Column(
              children: <Widget>[
                // Title

                Center(
                  child: Text(widget.creatableSong["song_family"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16)),
                ),
                // Subtitle
                Center(
                  child: Text(
                    widget.creatableSong["name"],
                    style: TextStyle(
                        fontWeight: FontWeight.w200,
                        color: Colors.grey,
                        fontSize: 11),
                  ),
                ),
                // Center(
                //     child: Text(widget.song.getName,
                //         style:
                //             TextStyle(color: Colors.white, fontSize: 16)))
              ],
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
              side: BorderSide(color: Theme.of(context).primaryColor, width: 3),
            ),
            elevation: 2.0,
            // fillColor: Theme.of(context).primaryColor,
            // padding:
            //     const EdgeInsets.symmetric(vertical: 0, horizontal: 22.0),
          ),
        ),
      ],
    );
  }
}
