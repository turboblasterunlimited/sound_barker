import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
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

class _SongPlaybackCardState extends State<SongPlaybackCard>
    with TickerProviderStateMixin {
  //   AutomaticKeepAliveClientMixin {
  // bool get wantKeepAlive => true;
  ImageController imageController;
  AnimationController renameAnimationController;
  bool _isPlaying = false;
  final _controller = TextEditingController();
  String tempName;
  CurrentActivity currentActivity;
  KaraokeCards cards;

  @override
  void initState() {
    tempName = widget.song.name;
    imageController = Provider.of<ImageController>(context, listen: false);
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
  }

  @override
  void dispose() {
    stopAll();
    renameAnimationController.dispose();
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
    imageController.mouthTrackSound(filePath: widget.song.amplitudesPath);
    await widget.soundController.startPlayer(widget.song.filePath, stopAll);
    print("song playback file path: ${widget.song.filePath}");
  }

  void deleteSong() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content:
            Text('Are you sure you want to delete ${widget.song.getName}?'),
        actions: <Widget>[
          FlatButton(
              child: Text("No, Don't delete it."),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('Yes. Delete it.'),
              onPressed: () {
                Navigator.of(ctx).pop();
                try {
                  widget.songs.removeSong(widget.song);
                  AnimatedList.of(context).removeItem(
                      widget.index,
                      (context, animation) => SongPlaybackCard(
                          widget.index,
                          widget.song,
                          widget.songs,
                          widget.soundController,
                          animation));
                } catch (e) {
                  showErrorDialog(ctx, e.toString());
                } finally {}
              })
        ],
      ),
    );
  }

  void renameSong() async {
    _controller.text = tempName;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: tempName.length,
    );
    void _submitNameChange(ctx) async {
      if (tempName == widget.song.name)
        Navigator.of(ctx).pop();
      else if (tempName != "") {
        Navigator.of(ctx).pop();
        await renameAnimationController.reverse();
        setState(() {
          widget.song.rename(tempName);
          widget.song.name = tempName;
        });
        renameAnimationController.forward();
      } else {
        setState(() => tempName = widget.song.name);
        Navigator.of(ctx).pop();
      }
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Center(child: Text('Rename Song')),
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

  selectSong() {
    cards.setCurrentCardSong(widget.song);
    currentActivity.setCardCreationStep(CardCreationSteps.speak);
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return SizeTransition(
      sizeFactor: widget.animation,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Playback button
          IconButton(
            color: Colors.blue,
            onPressed: () {
              if (_isPlaying) {
                stopAll();
              } else {
                startAll();
              }
            },
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow,
                color: Theme.of(context).primaryColor, size: 30),
          ),
          // Select song button
          Expanded(
            child: RawMaterialButton(
              onPressed: selectSong,
              child: FadeTransition(
                opacity: renameAnimationController,
                child: Column(
                  children: <Widget>[
                    // Title
                    Center(
                      child: Text(widget.song.songFamily,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 16)),
                    ),
                    // Subtitle
                    // Center(
                    //     child: Text(widget.song.getName,
                    //         style:
                    //             TextStyle(color: Colors.white, fontSize: 16)))
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
              padding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 22.0),
            ),
          ),
          // Menu button
          IconButton(
            onPressed: deleteSong,
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryColor, size: 30),
          ),
        ],
      ),
    );
  }
}
