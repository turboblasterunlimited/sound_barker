import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/singing_image.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';

import '../functions/error_dialog.dart';
import '../providers/image_controller.dart';
import '../providers/active_wave_streamer.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../providers/pictures.dart';
import '../services/wave_streamer.dart' as WaveStreamer;
import '../functions/error_dialog.dart';

class GenerateCardScreen extends StatefulWidget {
  static const routeName = 'record-message-screen';
  Song song;
  Picture picture;

  GenerateCardScreen(this.song, this.picture);

  @override
  _GenerateCardScreenState createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends State<GenerateCardScreen> {
  bool _isCapturing = false;
  StreamSubscription<double> waveStreamer;
  ImageController imageController;
  SoundController soundController;
  Song song;
  String cardFilePath;
  Pictures pictures;

  requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.photos,
      Permission.storage,
    ].request();
    // print(statuses[Permission.location]);
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    SystemChrome.setEnabledSystemUIOverlays([]);
    soundController = Provider.of<SoundController>(context, listen: false);
  }

  @override
  void dispose() {
    stopAll();
    super.dispose();
  }

  void stopAll() {
    waveStreamer?.cancel();
    imageController.blink(0);
    soundController.stopPlayer();
  }

  Future<void> startAll() async {
    stopAll();
    Provider.of<ActiveWaveStreamer>(context, listen: false)
        .waveStreamer
        ?.cancel();
    waveStreamer = WaveStreamer.performAudio(
        song.filePath, imageController, doneCapturing);
    Provider.of<ActiveWaveStreamer>(context, listen: false).waveStreamer =
        waveStreamer;
    soundController.startPlayer(song.filePath, song.backingTrackPath);
  }

  doneCapturing() async {
    cardFilePath = await FlutterScreenRecording.stopRecordScreen;

    setState(() {
      this._isCapturing = false;
    });
    print("Done Capturing: $_isCapturing");
    print("Card FilePath: $cardFilePath");
    showErrorDialog(context, cardFilePath);
  }

  _onStartScreenCapture() async {
    setState(() {
      this._isCapturing = true;
    });
    FlutterScreenRecording.startRecordScreen("BOBBY");

    await startAll();
    // captureScreen();
  }

  Future<void> setImageController() async {
    Future.delayed(Duration(seconds: 2), () {
      imageController = Provider.of<ImageController>(context, listen: false);
    });
  }


  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context, listen: false);
    setImageController();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
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
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: _onStartScreenCapture,
                      child: Text(
                        this._isCapturing ? "Generating..." : "Generate Card",
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
