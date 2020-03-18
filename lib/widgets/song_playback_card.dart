import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../functions/error_dialog.dart';
import '../providers/image_controller.dart';
import '../services/wave_streamer.dart' as WaveStreamer;

class SongPlaybackCard extends StatefulWidget {
  final int index;
  final Song song;
  final SoundController soundController;
  SongPlaybackCard(this.index, this.song, this.soundController);

  @override
  _SongPlaybackCardState createState() => _SongPlaybackCardState();
}

class _SongPlaybackCardState extends State<SongPlaybackCard> {
  ImageController imageController;

  @override
  void dispose() {
    widget.soundController.stopPlayer();
    super.dispose();
  }

  void playSong(context) async {
    final imageController = Provider.of<ImageController>(context, listen: false);
    String path = widget.song.filePath;
    try {
      WaveStreamer.performAudio(context, path, imageController);
      widget.soundController.stopPlayer();
      widget.soundController.startPlayer(path);
      widget.soundController.flutterSound.setVolume(1.0);
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  void deleteSong(song) async {
    final songs = Provider.of<Songs>(context, listen: false);
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Are you sure you want to delete ${song.name}?'),
        actions: <Widget>[
          FlatButton(
              child: Text("No, Don't delete it."),
              onPressed: () {
                Navigator.of(ctx).pop();
              }),
          FlatButton(
              child: Text('Yes. Delete it.'),
              onPressed: () {
                try {
                  songs.removeSong(song);
                } catch (e) {
                  showErrorDialog(ctx, e.toString());
                } finally {
                  Navigator.of(ctx).pop();
                }
              })
        ],
      ),
    );
  }

  void renameSong(song) async {
    String newName = song.name;

    void _submitNameChange(ctx) async {
      print("New name: $newName");
      try {
        await song.rename(newName);
      } catch (e) {
        showErrorDialog(context, e);
      }
      Navigator.of(ctx).pop();
    }

    await showDialog<Null>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Rename Song'),
        contentPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(10),
        children: <Widget>[
          TextFormField(
            initialValue: newName,
            onChanged: (name) {
              setState(() => newName = name);
            },
            onFieldSubmitted: (name) {
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
    context = context;
    final song = Provider.of<Song>(context);
    String songName = song.name;
    return Card(
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
            onTap: () => renameSong(song),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 18),
                children: [
                  WidgetSpan(
                    child: Text(songName),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // subtitle: Text(pet.name),
          trailing: IconButton(
            onPressed: () {
              deleteSong(song);
            },
            icon: Icon(Icons.delete, color: Colors.redAccent, size: 30),
          ),
        ),
      ),
    );
  }
}
