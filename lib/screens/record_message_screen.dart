import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';
import 'package:flutter_sound_lite/ios_quality.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/functions/app_storage_path.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:song_barker/services/amplitude_extractor.dart';
import 'package:song_barker/services/ffmpeg.dart';
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
  bool _isRecording = false;
  bool _messageExists = false;
  bool _hasShifted = false;
  String amplitudePath;
  String filePath;
  String alteredAmplitudePath;
  String alteredFilePath = myAppStoragePath + "/tempFile.aac";
  // 0 & 200
  double messageSpeed = 100;
  double messagePitch = 100;
  // -1 & 1
  double pitchCompensation = 0;
  double speedCompensation = 0;

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
    if (_messageExists) {
      File(filePath).deleteSync();
      File(amplitudePath).deleteSync();
    }
    if (File(alteredFilePath).existsSync()) {
      File(alteredFilePath).deleteSync();
      File(alteredAmplitudePath).deleteSync();
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
        this._hasShifted = false;
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
      this._messageExists = true;
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
    print("song playback file path: $audioFile");
  }

  void handlePlayStopButton() {
    _isPlaying
        ? stopPlayback()
        : _hasShifted
            ? startPlayback(alteredFilePath, alteredAmplitudePath)
            : startPlayback(filePath, amplitudePath);
    setState(() => _isPlaying = !_isPlaying);
  }

  void generateAlteredAudioFiles() async {
    pitchCompensation = 1 - (messageSpeed / 100);
    double pitchChange = (messagePitch / 100) - pitchCompensation;
    speedCompensation = 1 - (messagePitch / 100);
    double speedChange = (messageSpeed / 100) - speedCompensation;
    await FFMpeg.converter.execute(
        '-i $filePath -filter:a "asetrate=44100*$pitchChange,aresample=44100,atempo=$speedChange" -vn $alteredFilePath');
    await createAmplitudeFile(alteredFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add a personal message?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    Text("Pitch",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: messagePitch,
                        min: 0,
                        max: 200,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            messagePitch = value;
                            _hasShifted = true;
                          });
                        },
                        onChangeEnd: (value) async {
                          setState(() => messagePitch = value);
                          generateAlteredAudioFiles();
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Expanded(
                      child: ButtonBar(
                        children: <Widget>[
                          Ink(
                            height: 80,
                            width: 80,
                            decoration: ShapeDecoration(
                              color: _isRecording
                                  ? Colors.redAccent
                                  : Colors.white,
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
                              color: (_isRecording || !_messageExists)
                                  ? Colors.grey[350]
                                  : Colors.blue,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              disabledColor: Colors.grey,
                              color:
                                  _messageExists ? Colors.black38 : Colors.grey,
                              icon: _isPlaying
                                  ? Icon(Icons.stop)
                                  : Icon(Icons.play_arrow),
                              iconSize: 50,
                              onPressed: _isRecording || !_messageExists
                                  ? null
                                  : handlePlayStopButton,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              builder: (context) => GenerateCardScreen(
                                  widget.song, widget.picture),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    Text("Speed",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Slider(
                        value: messageSpeed,
                        min: 0,
                        max: 200,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: (value) async {
                          setState(() => messageSpeed = value);
                          generateAlteredAudioFiles();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
