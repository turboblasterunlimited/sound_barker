import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/playback_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/error_dialog.dart';
import '../providers/flutter_sound_controller.dart';

class CreatableSongCard extends StatefulWidget {
  final CreatableSong creatableSong;
  final FlutterSoundController soundController;
  final KaraokeCards cards;
  final CurrentActivity currentActivity;

  //final void Function() cancelSelectionCallback;

  CreatableSongCard(this.creatableSong, this.soundController, this.cards,
      this.currentActivity /*, this.cancelSelectionCallback*/);

  @override
  _CreatableSongCardState createState() => _CreatableSongCardState();
}

class _CreatableSongCardState extends State<CreatableSongCard> {
  bool isPlaying = false;
  late KaraokeCards cards;
  bool isLoading = false;

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  VoidCallback stopPlayerCallBack() {
    setState(() => isPlaying = false);
    return () {
      widget.soundController.stopPlayer();
      if (mounted) {
        setState(() => isPlaying = false);
      }
    };
  }

  void playSong() async {
    try {
      setState(() => isLoading = true);
      await widget.soundController.startPlayer(
          "https://storage.googleapis.com/song_barker_sequences/" +
              widget.creatableSong.backingTrackUrl,
          stopCallback: stopPlayerCallBack,
          mediaType: Media.webfile);
      Future.delayed(Duration(milliseconds: 50), () {
        setState(() {
          isLoading = false;
          isPlaying = true;
        });
      });
      print("Play song successfully started");
    } catch (e) {
      showError(context, e.toString());
    }
  }

  void selectSongFormula() {
    widget.cards.setCurrentSong(null);
    widget.cards.setCurrentSongFormula(widget.creatableSong);

    Future.delayed(
      Duration(milliseconds: 1500),
      () => widget.currentActivity.setCardCreationStep(CardCreationSteps.speak),
    );
  }

  void stopSong() {
    widget.soundController.stopPlayer();
    setState(() => isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);

    return PlaybackCard(
        canDelete: false,
        isSelected: cards.current!.songFormula == widget.creatableSong,
        select: selectSongFormula,
        name: widget.creatableSong.fullName,
        isLoading: isLoading,
        startAll: playSong,
        stopAll: stopSong,
        isPlaying: isPlaying);
  }
}
