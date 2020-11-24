import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import '../providers/barks.dart';
import '../providers/image_controller.dart';
import './error_dialog.dart';

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

class _BarkPlaybackCardState extends State<BarkPlaybackCard>
    with TickerProviderStateMixin {
  //   AutomaticKeepAliveClientMixin {
  // bool get wantKeepAlive => true;
  AnimationController renameAnimationController;
  ImageController imageController;
  bool _isPlaying = false;
  bool _isLoading = false;
  final _controller = TextEditingController();
  String tempName;
  KaraokeCards cards;
  CurrentActivity currentActivity;

  @override
  void initState() {
    tempName = widget.bark.name;
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
    imageController = Provider.of<ImageController>(context, listen: false);
  }

  @override
  void dispose() {
    renameAnimationController.dispose();
    stopAll();
    super.dispose();
  }

  void stopAll() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      imageController.stopAnimation();
      widget.soundController.stopPlayer();
    }
  }

  Future<void> play() async {
    setState(() => _isPlaying = true);
    await widget.soundController
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
    print("bark playback");
    print("bark id: ${widget.bark.fileId}");
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

  void renameBark() async {
    _controller.text = tempName;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: tempName.length,
    );
    void _submitNameChange(ctx) async {
      if (tempName == widget.bark.name)
        Navigator.of(ctx).pop();
      else if (tempName != "") {
        Navigator.of(ctx).pop();
        await renameAnimationController.reverse();
        setState(() {
          widget.bark.rename(tempName);
          widget.bark.name = tempName;
        });
        renameAnimationController.forward();
      } else {
        setState(() => tempName = widget.bark.name);
        Navigator.of(ctx).pop();
      }
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        title: Center(
          child: Text('Rename Bark'),
        ),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            controller: _controller,
            autofocus: true,
            onChanged: (newName) {
              setState(() => tempName = newName);
            },
            onFieldSubmitted: (_) {
              _submitNameChange(ctx);
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please provide a name.';
              }
              return null;
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              _submitNameChange(ctx);
            },
          ),
        ],
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
              color: Theme.of(context).primaryColor, size: 30));
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    bool isSelected = cards.current.hasBark(widget.bark);

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
              child: FadeTransition(
                opacity: renameAnimationController,
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
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
