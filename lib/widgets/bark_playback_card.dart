import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
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

  void startAll() async {
    setState(() => _isPlaying = true);
    imageController.mouthTrackSound(filePath: widget.bark.amplitudesPath);
    await widget.soundController.startPlayer(widget.bark.filePath, stopAll);
  }

  void playBark() async {
    try {
      startAll();
    } catch (e) {
      showError(context, e.toString());
    }
  }

  void deleteBark() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${widget.bark.name}?'),
        actions: <Widget>[
          FlatButton(
              child: Text("No, Don't delete it."),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('Yes. Delete it.'),
              onPressed: () {
                widget.deleteCallback(widget.bark, widget.index);
                Navigator.of(ctx).pop();
              })
        ],
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

  selectBark() {
    if (currentActivity.isTwo)
      cards.setCurrentShortBark(widget.bark);
    else if (currentActivity.isThree)
      cards.setCurrentMediumBark(widget.bark);
    else if (currentActivity.isFour) cards.setCurrentLongBark(widget.bark);

    currentActivity.setNextSubStep();
  }

  Widget _getAudio() {
    if (widget.bark.hasFile) {
      return _playbackButton();
    } else {
      return FutureBuilder(
          future: widget.bark.retrieve(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print("it's done:");
              return _playbackButton();
            } else if (snapshot.hasError) {
              IconButton(
                onPressed: null,
                icon: Icon(
                  LineAwesomeIcons.exclamation_circle,
                  color: Theme.of(context).errorColor,
                ),
              );
            } else
              return IconButton(
                  onPressed: null,
                  icon: SpinKitWave(
                      size: 10, color: Theme.of(context).primaryColor));
          });
    }
  }

  Widget _playbackButton() {
    return IconButton(
        color: Colors.blue,
        onPressed: playBark,
        icon: _isPlaying
            ? Icon(Icons.stop, color: Theme.of(context).errorColor, size: 30)
            : Icon(Icons.play_arrow,
                color: Theme.of(context).primaryColor, size: 30));
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    if (true)
      return SizeTransition(
        sizeFactor: widget.animation,
        child: Row(
          children: <Widget>[
            // Playback button
            _getAudio(),
            // Select bark button
            Expanded(
              child: RawMaterialButton(
                onPressed: selectBark,
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
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                            // Subtitle
                            TextSpan(
                              text: " " + widget.bark.length,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      )

                          // Subtitle
                          )
                    ],
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor, width: 3),
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
