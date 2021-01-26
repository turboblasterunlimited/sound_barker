import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';

class BarkPlaybackCard extends StatefulWidget {
  final int index;
  final Bark bark;
  final Barks barks;
  final SoundController soundController;
  final Animation<double> animation;
  final Function deleteCallback;
  BarkPlaybackCard(
      this.index, this.bark, this.barks, this.soundController, this.animation,
      {this.deleteCallback});

  @override
  _BarkPlaybackCardState createState() => _BarkPlaybackCardState();
}

class _BarkPlaybackCardState extends State<BarkPlaybackCard> {
  ImageController imageController;
  bool _isPlaying = false;
  bool _isLoading = false;
  String tempName;
  KaraokeCards cards;
  CurrentActivity currentActivity;

  void stopAll() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      imageController.stopAnimation();
      widget.soundController.stopPlayer();
    }
  }

  Future<void> play() async {
    setState(() => _isPlaying = true);
    widget.soundController
        .startPlayer(widget.bark.filePath, stopCallback: stopAll);
    imageController.mouthTrackSound(filePath: widget.bark.amplitudesPath);
  }

  Future<void> download() async {
    setState(() => _isLoading = true);
    await widget.bark.reDownload();
    setState(() => _isLoading = false);
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

  void deleteBark() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => CustomDialog(
        header: "Delete Bark?",
        bodyText: 'Are you sure you want to delete ${widget.bark.name}?',
        primaryFunction: (BuildContext modalContext) async {
          widget.deleteCallback(widget.bark, widget.index);
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
    if (currentActivity.isTwo)
      cards.setCurrentShortBark(widget.bark);
    else if (currentActivity.isThree)
      cards.setCurrentMediumBark(widget.bark);
    else if (currentActivity.isFour) cards.setCurrentLongBark(widget.bark);
    Future.delayed(Duration(milliseconds: 500), currentActivity.setNextSubStep);
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
          onPressed: stopAll,
          icon:
              Icon(Icons.stop, color: Theme.of(context).errorColor, size: 30));
    else
      return IconButton(
        color: Colors.blue,
        onPressed: startAll,
        icon: Icon(Icons.play_arrow,
            color: Theme.of(context).primaryColor, size: 30),
      );
  }

  @override
  Widget build(BuildContext context) {
    cards ??= Provider.of<KaraokeCards>(context, listen: false);
    currentActivity ??= Provider.of<CurrentActivity>(context, listen: false);
    bool isSelected = cards.current.hasBark(widget.bark);
    imageController ??= Provider.of<ImageController>(context, listen: false);

    return SizeTransition(
      sizeFactor: widget.animation,
      child: Row(
        children: <Widget>[
          // Playback button
          _getAudioButton(),
          // Select bark button
          Expanded(
            child: RawMaterialButton(
              onPressed: selectBark,
              fillColor: isSelected ? Theme.of(context).primaryColor : null,
              child: Column(
                children: <Widget>[
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          // Title
                          TextSpan(
                            text: widget.bark.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          // Subtitle
                          TextSpan(
                            text: " " + widget.bark.length,
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 2.0,
              // fillColor: Theme.of(context).primaryColor,
              // padding:
              //     const EdgeInsets.symmetric(vertical: 0, horizontal: 22.0),
            ),
          ),
          // Menu button
          if (!widget.bark.isStock)
            IconButton(
              onPressed: deleteBark,
              icon: Icon(Icons.more_vert,
                  color: Theme.of(context).primaryColor, size: 30),
            ),
          if (widget.bark.isStock)
            Padding(
              padding: EdgeInsets.only(left: 20),
            )
        ],
      ),
    );
  }
}
