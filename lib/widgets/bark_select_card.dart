import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:io';

import '../providers/barks.dart';
import '../providers/songs.dart';

class BarkSelectCard extends StatefulWidget {
  final int index;
  final Bark bark;
  final songId;
  BarkSelectCard(this.index, this.bark, this.songId);

  @override
  _BarkSelectCardState createState() => _BarkSelectCardState();
}

class _BarkSelectCardState extends State<BarkSelectCard> {
  FlutterSound flutterSound;
  StreamSubscription _playerSubscription;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
  }

  @override
  void dispose() {
    flutterSound.stopPlayer();
    super.dispose();
  }

  void playBark() async {
    String path = widget.bark.filePath;
    //print('playing bark!');
    //print(path);
    if (File(path).exists() == null) {
      //print("No audio file found at: $path");
      return;
    }
    try {
      path = await flutterSound.startPlayer(path);
      await flutterSound.setVolume(1.0);

      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          this.setState(() {
            this._isPlaying = true;
          });
        }
      });
    } catch (e) {
      //print("Error: $e");
    }
  }

  void createSong(songs, songId) async {
    String responseBody = await widget.bark.createSongOnServerAndRetrieve(songId);
    Song song = Song();
    song.retrieveSong(responseBody);
    songs.addSong(song);
  }

  @override
  Widget build(BuildContext context) {
    final songs = Provider.of<Songs>(context, listen: false);
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: ListTile(
          leading: IconButton(
            onPressed: () {
              createSong(songs, widget.songId);
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.queue_music, color: Colors.blue, size: 30),
          ),
          title: Text(widget.bark.name),
          // subtitle: Text(''),
          trailing: IconButton(
            color: Colors.blue,
            onPressed: () {
              // Playback bark.
              playBark();
            },
            icon: Icon(Icons.play_arrow, color: Colors.black, size: 40),
          ),
        ),
      ),
    );
  }
}
