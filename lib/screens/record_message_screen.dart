import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';
import 'package:flutter_sound_lite/ios_quality.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:song_barker/widgets/singing_image.dart';
import 'dart:async';
import 'dart:io';

import '../providers/songs.dart';
import '../providers/pictures.dart';
import './generate_card_screen.dart';
import '../providers/sound_controller.dart';
import '../functions/amplitude_file_generator.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

class RecordMessageScreen extends StatefulWidget {
  static const routeName = 'record-message-screen';
  Song song;
  Picture picture;
  RecordMessageScreen(this.song, this.picture);

  @override
  _RecordMessageScreenState createState() => _RecordMessageScreenState();
}

class _RecordMessageScreenState extends State<RecordMessageScreen> {
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSoundRecorder flutterSound;
  ImageController imageController;
  SoundController soundController;
  bool _isPlaying = false;
  String amplitudePath;
  bool _isRecording = false;
  String filePath;
  bool messageExists = false;

  @override
  void initState() {
    super.initState();
    soundController = Provider.of<SoundController>(context, listen: false);
    imageController = Provider.of<ImageController>(context, listen: false);
    flutterSound = FlutterSoundRecorder();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startRecorder() async {
    if (messageExists) {
      File(filePath).deleteSync();
      File(amplitudePath).deleteSync();
    }
    try {
      this.filePath = await flutterSound.startRecorder(
          iosQuality: IosQuality.MAX, sampleRate: 44100, bitRate: 192000);
      print('start message recorder: $filePath');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {});

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      setState(() {
        this._isRecording = false;
      });
    }
  }

  void stopRecorder() async {
    setState(() {
      this._isRecording = false;
      this.messageExists = true;
    });

    try {
      await flutterSound.stopRecorder();
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }

    amplitudePath = await createAmplitudeFile(filePath);
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  onStartRecorderPressed() {
    if (flutterSound.isRecording) return stopRecorder;
    return startRecorder;
  }

  void stopPlayback() {
    imageController.stopAnimation();
    soundController.stopPlayer();
  }

  Function stopPlayerCallBack() {
    return () {
      stopPlayback();
      if (mounted) setState(() => _isPlaying = false);
    };
  }

  void startPlayback(audioFile, amplitudeFile) async {
    stopPlayback();
    imageController.mouthTrackSound(amplitudeFile);
    await soundController.startPlayer(audioFile, stopPlayerCallBack());
    print("song playback file path: ${audioFile}");
  }

  void handlePlayStopButton() {
    _isPlaying ? stopPlayback() : startPlayback(filePath, amplitudePath);
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Record a personal message?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          SingingImage(widget.picture),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonBar(
                  children: <Widget>[
                    Ink(
                      height: 80,
                      width: 80,
                      decoration: ShapeDecoration(
                        color: _isRecording ? Colors.redAccent : Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        color: Colors.black38,
                        icon: Icon(Icons.mic),
                        iconSize: 50,
                        onPressed: onStartRecorderPressed(),
                      ),
                    ),
                    Ink(
                      height: 80,
                      width: 80,
                      decoration: ShapeDecoration(
                        color: (_isRecording || !messageExists)
                            ? Colors.grey[350]
                            : Colors.blue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        disabledColor: Colors.grey,
                        color: messageExists ? Colors.black38 : Colors.grey,
                        icon: _isPlaying
                            ? Icon(Icons.stop)
                            : Icon(Icons.play_arrow),
                        iconSize: 50,
                        onPressed: _isRecording || !messageExists
                            ? null
                            : handlePlayStopButton,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Or Skip ->",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GenerateCardScreen(widget.song, widget.picture),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
