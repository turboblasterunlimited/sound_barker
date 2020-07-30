import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';

import '../widgets/error_dialog.dart';
import '../providers/sound_controller.dart';

class CreatableSongCard extends StatefulWidget {
  final CreatableSong creatableSong;
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
              widget.creatableSong.backingTrackUrl,
          stopPlayerCallBack());
      Future.delayed(Duration(milliseconds: 50), () {
        setState(() => isPlaying = true);
      });
    } catch (e) {
      showError(context, e);
    }
  }

  void _selectSongFormula() {
    print("formula selected");
    widget.cards.setCurrentSongFormula(widget.creatableSong);
    widget.currentActivity.setCardCreationStep(CardCreationSteps.speak);
    widget.currentActivity.setCardCreationSubStep(CardCreationSubSteps.one);
    Navigator.pop(context);
  }

  void _handlePlayStopButton() {
    if (isPlaying) {
      widget.soundController.stopPlayer();
      setState(() => isPlaying = false);
    } else {
      playSong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Playback button
        IconButton(
          color: Colors.blue,
          onPressed: _handlePlayStopButton,
          icon: isPlaying
              ? Icon(Icons.stop, color: Theme.of(context).errorColor, size: 30)
              : Icon(Icons.play_arrow,
                  color: Theme.of(context).primaryColor, size: 30),
        ),
        // Select song button
        Expanded(
          child: RawMaterialButton(
            onPressed: _selectSongFormula,
            child: Column(
              children: <Widget>[
                // Title
                Center(
                  child: Text(widget.creatableSong.fullName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 16)),
                ),
                // Subtitle
                // Center(
                //   child: Text(
                //     widget.creatableSong["name"],
                //     style: TextStyle(
                //         fontWeight: FontWeight.w200,
                //         color: Colors.grey,
                //         fontSize: 11),
                //   ),
                // ),
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
