import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

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
  bool _isPlaying = false;
  KaraokeCards cards;
  bool _isLoading = false;

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  Function stopPlayerCallBack() {
    return () {
      widget.soundController.stopPlayer();
      if (mounted) setState(() => _isPlaying = false);
    };
  }

  void playSong() async {
    try {
      setState(() => _isLoading = true);
      if (widget.creatableSong.backingTrackOffset != null)
        widget.soundController.player.seekTo(Duration(milliseconds: widget.creatableSong.backingTrackOffset));
      await widget.soundController.startPlayer(
          "https://storage.googleapis.com/song_barker_sequences/" +
              widget.creatableSong.backingTrackUrl,
          stopCallback: stopPlayerCallBack(),
          url: true);
      Future.delayed(Duration(milliseconds: 50), () {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      });
    } catch (e) {
      showError(context, e);
    }
  }

  void _selectSongFormula() {
    print("formula selected");
    widget.cards.setCurrentSong(null);
    widget.cards.setCurrentSongFormula(widget.creatableSong);
    Future.delayed(
      Duration(milliseconds: 500),
      () => widget.currentActivity.setCardCreationStep(CardCreationSteps.speak),
    );
  }

  void stopSong() {
    widget.soundController.stopPlayer();
    setState(() => _isPlaying = false);
  }

  Widget _getAudioButton() {
    if (_isLoading)
      return IconButton(
        onPressed: null,
        icon: SpinKitWave(size: 10, color: Theme.of(context).primaryColor),
      );
    if (_isPlaying)
      return IconButton(
          color: Colors.blue,
          onPressed: stopSong,
          icon:
              Icon(Icons.stop, color: Theme.of(context).errorColor, size: 30));
    else
      return IconButton(
        color: Colors.blue,
        onPressed: playSong,
        icon: Icon(Icons.play_arrow,
            color: Theme.of(context).primaryColor, size: 30),
      );
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    bool isSelected = cards.current.songFormula == widget.creatableSong;

    return Row(
      children: <Widget>[
        // Playback button
        _getAudioButton(),
        // Select song button
        Expanded(
          child: RawMaterialButton(
            onPressed: _selectSongFormula,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    widget.creatableSong.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
              side: BorderSide(color: Theme.of(context).primaryColor, width: 3),
            ),
            elevation: 2.0,
            fillColor: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }
}
