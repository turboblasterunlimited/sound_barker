import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:io';

import '../providers/barks.dart';
import '../providers/pets.dart';

class BarkPlaybackButton extends StatefulWidget {
  final int index;
  final Bark bark;
  BarkPlaybackButton(this.index, this.bark);

  @override
  _BarkPlaybackButtonState createState() => _BarkPlaybackButtonState();
}

class _BarkPlaybackButtonState extends State<BarkPlaybackButton> {
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
    flutterSound.stopRecorder();
    super.dispose();
  }

  void playBark() async {
    String path = widget.bark.filePath;
    print('playing bark!');
    print(path);
    if (File(path).exists() == null) {
      print("No audio file found at: $path");
      return;
    }
    try {
    path = await flutterSound.startPlayer(path);
    await flutterSound.setVolume(1.0);

    print('startPlayer: $path');

    _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        this.setState(() {
          this._isPlaying = true;
        });
      }
    });
    } catch(e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bark = Provider.of<Bark>(context, listen: false);
    final pet = Provider.of<Pets>(context, listen: false).getById(bark.petId);
    String barkName = bark.name == null
        ? "${pet.name}_${(widget.index + 1).toString()}"
        : bark.name;
    return Column(
      children: <Widget>[
        Text(
          barkName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        RaisedButton(
          color: Colors.redAccent,
          elevation: 0,
          onPressed: () {
            // Playback bark.
            playBark();
          },
          child: Icon(Icons.play_arrow, color: Colors.purple, size: 30),
        ),
      ],
    );
  }
}
