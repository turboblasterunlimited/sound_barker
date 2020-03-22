import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../functions/error_dialog.dart';
import '../providers/image_controller.dart';
import '../services/wave_streamer.dart' as WaveStreamer;

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
  ImageController imageController;
  AnimationController renameAnimationController;

  @override
  void initState() {
    renameAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    super.initState();
    renameAnimationController.forward();
  }

  @override
  void dispose() {
    renameAnimationController.dispose();
    widget.soundController.stopPlayer();
    super.dispose();
  }

  void playSong(context) async {
    final imageController =
        Provider.of<ImageController>(context, listen: false);
    String filePath = widget.song.filePath;
    try {
      WaveStreamer.performAudio(filePath, imageController);
      widget.soundController.stopPlayer();
      widget.soundController.startPlayer(filePath);
      widget.soundController.flutterSound.setVolume(1.0);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void deleteSong() async {
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${widget.song.name}?'),
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
    void _submitNameChange(ctx) async {
      try {
        widget.song.rename(widget.song.name);
      } catch (e) {
        showErrorDialog(context, e);
      }
      Navigator.of(ctx).pop();
      await renameAnimationController.reverse();
      setState(() {});
      renameAnimationController.forward();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Rename Song'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            initialValue: widget.song.name,
            onChanged: (name) {
              widget.song.name = name;
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
              child: Text("NEVERMIND"),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
            child: Text('RENAME'),
            onPressed: () {
              _submitNameChange(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String songName = widget.song.name;
    return SizeTransition(
      sizeFactor: widget.animation,
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: ListTile(
            leading: IconButton(
              color: Colors.blue,
              onPressed: () {
                playSong(context);
              },
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 40),
            ),
            title: GestureDetector(
              onTap: () => renameSong(),
              child: Center(
                child: FadeTransition(
                  opacity: renameAnimationController,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        WidgetSpan(
                          child: Text(songName, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(Icons.edit,
                                color: Colors.grey[400], size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // subtitle: Text(pet.name),
            trailing: IconButton(
              onPressed: () {
                deleteSong();
              },
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
