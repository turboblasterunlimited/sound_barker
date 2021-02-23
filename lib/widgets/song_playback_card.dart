import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/playback_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../widgets/error_dialog.dart';
import '../providers/image_controller.dart';

class SongPlaybackCard extends StatefulWidget {
  final int index;
  final Song song;
  final Songs songs;
  final SoundController soundController;
  final Animation animation;
  SongPlaybackCard(
      this.index, this.song, this.songs, this.soundController, this.animation);

  @override
  _SongPlaybackCardState createState() => _SongPlaybackCardState();
}

class _SongPlaybackCardState extends State<SongPlaybackCard> {
  ImageController imageController;
  bool isPlaying = false;
  bool isLoading = false;
  String tempName;
  CurrentActivity currentActivity;
  KaraokeCards cards;

  void stopAll() {
    if (isPlaying) {
      widget.soundController.stopPlayer();
      imageController.stopAnimation();
      setState(() => isPlaying = false);
    }
  }

  void deleteSong(con) async {
    await showDialog<Null>(
      context: con,
      builder: (ctx) => CustomDialog(
        header: 'Delete Song?',
        bodyText: 'Are you sure you want to delete ${widget.song.getName}?',
        isYesNo: true,
        iconPrimary: Icon(
          CustomIcons.modal_trashcan,
          size: 42,
          color: Colors.grey[300],
        ),
        iconSecondary: Icon(
          CustomIcons.modal_paws_topleft,
          size: 42,
          color: Colors.grey[300],
        ),
        secondaryButtonText: 'Yes',
        primaryButtonText: 'No',
        secondaryFunction: (con) {
          Navigator.of(con).pop();
          try {
            AnimatedList.of(context).removeItem(
                widget.index,
                (context, animation) => SongPlaybackCard(
                    widget.index,
                    widget.song,
                    widget.songs,
                    widget.soundController,
                    animation));
            widget.songs.removeSong(widget.song);
          } catch (e) {
            print(e);
            showError(context, "Something went wrong.");
          }
        },
        primaryFunction: (con) => Navigator.of(con).pop(),
      ),
    );
  }

  void selectSong() async {
    if (!widget.song.hasFile) await download();
    cards.setCurrentSongFormula(null);
    cards.setCurrentSong(widget.song);
    stopAll();
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        currentActivity.setCardCreationStep(CardCreationSteps.speak);
        currentActivity.setCardCreationSubStep(CardCreationSubSteps.seven);
      },
    );
  }

  Future<void> play() async {
    setState(() => isPlaying = true);
    widget.soundController
        .startPlayer(widget.song.filePath, stopCallback: stopAll);
    imageController.mouthTrackSound(filePath: widget.song.amplitudesPath);
  }

  Future<void> download() async {
    setState(() => isLoading = true);
    await widget.song.reDownload();
    setState(() => isLoading = false);
  }

  void startAll() async {
    if (widget.song.hasFile) {
      try {
        play();
      } catch (e) {
        showError(context, "playback error: $e");
        print("song playback error: $e");
        await download();
        play();
      }
    } else {
      await download();
      play();
    }
    print("bark playback");
    print("bark id: ${widget.song.fileId}");
  }

  @override
  Widget build(BuildContext context) {
    cards ??= Provider.of<KaraokeCards>(context, listen: false);
    currentActivity ??= Provider.of<CurrentActivity>(context, listen: false);
    bool isSelected = cards.current.hasSong(widget.song);
    imageController ??= Provider.of<ImageController>(context, listen: false);

    return SizeTransition(
      sizeFactor: widget.animation,
      child: PlaybackCard(
          canDelete: true,
          delete: () => deleteSong(context),
          isSelected: isSelected,
          select: selectSong,
          name: widget.song.songFamily,
          isLoading: isLoading,
          startAll: startAll,
          stopAll: stopAll,
          isPlaying: isPlaying),
    );
  }
}
