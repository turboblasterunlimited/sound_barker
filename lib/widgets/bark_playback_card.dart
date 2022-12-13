import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/playback_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flutter_sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';

// ignore: must_be_immutable
class BarkPlaybackCard extends StatefulWidget {
  final int index;
  final Bark bark;
  final Barks barks;
  final FlutterSoundController soundController;
  final Animation<double> animation;
  final Function? deleteCallback;
  Color? color;
  BarkPlaybackCard(
      this.index, this.bark, this.barks, this.soundController, this.animation,
      {this.deleteCallback, this.color});

  @override
  _BarkPlaybackCardState createState() => _BarkPlaybackCardState();
}

class _BarkPlaybackCardState extends State<BarkPlaybackCard> {
  ImageController? imageController;
  bool isPlaying = false;
  bool isLoading = false;
  String? tempName;
  KaraokeCards? cards;
  CurrentActivity? currentActivity;

  void stopAll() {
    if (isPlaying) {
      setState(() => isPlaying = false);
      imageController!.stopAnimation();
      widget.soundController.stopPlayer();
    }
  }

  Future<void> play() async {
    setState(() => isPlaying = true);
    widget.soundController
        .startPlayer(widget.bark.filePath!, stopCallback: stopAll);
    imageController!.mouthTrackSound(filePath: widget.bark.amplitudesPath);
  }

  Future<void> download() async {
    setState(() => isLoading = true);
    await widget.bark.reDownload();
    setState(() => isLoading = false);
  }

  void startAll() async {
    if (widget.bark.hasFile) {
      try {
        play();
      } catch (e) {
        print("bark playback error: $e");
        await download();
        play();
      }
    } else {
      await download();
      play();
    }
    print("bark id: ${widget.bark.filePath}");
  }

  void deleteBark(con) async {
    await showDialog<Null>(
      context: con,
      builder: (ctx) => CustomDialog(
        header: "Delete Bark?",
        bodyText: 'Are you sure you want to delete ${widget.bark.name}?',
        primaryFunction: (BuildContext modalContext) async {
          widget.deleteCallback!(widget.bark, widget.index);
          Navigator.of(ctx).pop();
        },
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
        isYesNo: true,
      ),
    );
  }

  selectBark() async {
    if (currentActivity!.isTwo)
      cards!.setCurrentShortBark(widget.bark);
    else if (currentActivity!.isThree)
      cards!.setCurrentMediumBark(widget.bark);
    else if (currentActivity!.isFour) cards!.setCurrentLongBark(widget.bark);
    Future.delayed(
        Duration(milliseconds: 500), currentActivity!.setNextSubStep);
  }

  @override
  Widget build(BuildContext context) {
    cards ??= Provider.of<KaraokeCards>(context, listen: false);
    currentActivity ??= Provider.of<CurrentActivity>(context, listen: false);
    imageController ??= Provider.of<ImageController>(context, listen: false);

    return SizeTransition(
      sizeFactor: widget.animation,
      child: PlaybackCard(
          barkLength: widget.bark.length,
          color: widget.color,
          delete: () => deleteBark(context),
          canDelete: !widget.bark.isStock!,
          isSelected: cards!.current!.hasBark(widget.bark),
          select: selectBark,
          name: widget.bark.name!,
          isLoading: isLoading,
          startAll: startAll,
          stopAll: stopAll,
          isPlaying: isPlaying),
    );
  }
}
