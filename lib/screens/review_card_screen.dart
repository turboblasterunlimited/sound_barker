import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/singing_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'dart:async';
import 'dart:io';

import '../providers/image_controller.dart';
import '../providers/active_wave_streamer.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../services/wave_streamer.dart' as WaveStreamer;
import '../functions/error_dialog.dart';




class ReviewCardScreen extends StatefulWidget {
  static const routeName = 'record-message-screen';
  String songId;

  ReviewCardScreen(this.songId);

  @override
  _ReviewCardScreenState createState() => _ReviewCardScreenState();
}

class _ReviewCardScreenState extends State<ReviewCardScreen> {
  bool _isCapturing = false;
  StreamSubscription<double> waveStreamer;
  ImageController imageController;
  SoundController soundController;
  Song song;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    imageController = Provider.of<ImageController>(context, listen: false);
    soundController = Provider.of<SoundController>(context, listen: false);
    // WHEN WE ADD PERSONAL CARD MESSAGE, THIS WILL BE A LINK TO A TEMP FILE THAT WILL BE DELETED AFTER CARD IS CREATED.
    song = Provider.of<Songs>(context, listen: false).findById(widget.songId);
  }

    void stopAll() {
    waveStreamer?.cancel();
    imageController.setMouth(0);
    soundController.stopPlayer();
  }

  void startAll() {
    stopAll();
    Provider.of<ActiveWaveStreamer>(context, listen: false).waveStreamer?.cancel();
    waveStreamer = WaveStreamer.performAudio(song.filePath, imageController);
    Provider.of<ActiveWaveStreamer>(context, listen: false).waveStreamer = waveStreamer;
    soundController.startPlayer(song.filePath);
    // widget.soundController.startPlayer(widget.song.filePath, widget.song.backingTrackPath);
  }

  void playSong() async {
    try {
      // stopAll();
      startAll();
    } catch (e) {
      showErrorDialog(context, e);
    }
  }

  _onStartScreenCapture() {
    playSong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).accentColor, size: 30),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
      ),
      body: Column(
        children: <Widget>[
          SingingImage(),
          Expanded(
            child: Column(
              children: <Widget>[
                ButtonBar(
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: _onStartScreenCapture,
                      child: Text(
                        "Generate Card",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        // side: BorderSide(color: Colors.red),
                      ),
                      elevation: 2.0,
                      fillColor: this._isCapturing
                          ? Colors.redAccent[200]
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
