import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/singing_image.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import '../functions/app_storage_path.dart';
import '../functions/error_dialog.dart';
import '../providers/image_controller.dart';
import '../providers/active_wave_streamer.dart';
import '../providers/sound_controller.dart';
import '../providers/songs.dart';
import '../providers/pictures.dart';
import '../services/wave_streamer.dart' as WaveStreamer;
import '../functions/error_dialog.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log_level.dart';

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
  String cardFilePath;
  Pictures pictures;
  bool isPlaying;
  static final FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();
  static final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();


  requestPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.photos,
      Permission.storage,
    ].request();
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
    imageController.mouthOpen(0);
    soundController.stopPlayer();
  }

  Function stopPlayerCallBack() {
    return () => setState(() {
          isPlaying = false;
          stopAll();
        });
  }

  Future<void> startAll() async {
    stopAll();
    Provider.of<ActiveWaveStreamer>(context, listen: false)
        .waveStreamer
        ?.cancel();
    waveStreamer = WaveStreamer.performAudio(
        widget.song.filePath, imageController, doneCapturing);
    Provider.of<ActiveWaveStreamer>(context, listen: false).waveStreamer =
        waveStreamer;
    soundController.startPlayer(widget.song.filePath, stopPlayerCallBack());
  }

  doneCapturing() async {
    // write code here

    setState(() {
      this._isCapturing = false;
    });
    print("Done Capturing: $_isCapturing");
    print("Card FilePath: $cardFilePath");
    // await _flutterFFmpeg.execute(
    //         "-hide_banner -loglevel panic -i $filePath $filePathBase.wav");

    // ffmpeg -i in.mp4 -filter:v "crop=out_w:out_h:x:y" out.mp4

    showErrorDialog(context, cardFilePath);
  }

  _onStartScreenCapture() async {
    setState(() {
      this._isCapturing = true;
    });
    await startAll();
  }


  @override
  Widget build(BuildContext context) {


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
          SingingImage(widget.picture),
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
