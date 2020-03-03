import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';

import '../providers/songs.dart';
import '../providers/pets.dart';
import '../functions/error_dialog.dart';

class SongPlaybackCard extends StatefulWidget {
  final int index;
  final Song song;
  final FlutterSound flutterSound;
  SongPlaybackCard(this.index, this.song, this.flutterSound);

  @override
  _SongPlaybackCardState createState() => _SongPlaybackCardState();
}

class _SongPlaybackCardState extends State<SongPlaybackCard> {

  @override
  void dispose() {
    widget.flutterSound.stopPlayer();
    super.dispose();
  }

  void playSong() async {
    String path = widget.song.filePath;
    if (File(path).exists() == null) {
      return;
    }
    try {
      widget.flutterSound.stopPlayer();
      path = await widget.flutterSound.startPlayer(path);
      await widget.flutterSound.setVolume(1.0);
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
                  song.removeFromStorage();
                  song.deleteFromServer();
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
    final song = Provider.of<Song>(context);
    // final pet = Provider.of<Pets>(context, listen: false).getById(song.petId);
    // final String placeholderName =
    //     "${pet.name}_${(widget.index + 1).toString()}";

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
              playSong();
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