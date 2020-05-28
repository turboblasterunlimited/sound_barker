import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';
import 'package:flutter_sound_lite/ios_quality.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:song_barker/tools/app_storage_path.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:song_barker/tools/amplitude_extractor.dart';
import 'package:song_barker/tools/ffmpeg.dart';
import 'dart:async';
import 'dart:io';

import '../providers/sound_controller.dart';
import '../tools/amplitude_extractor.dart';

class MessageCreator extends StatefulWidget {
  final updateMessageFilePathCallback;
  MessageCreator(this.updateMessageFilePathCallback);

  @override
  MessageCreatorState createState() => MessageCreatorState();
}

class MessageCreatorState extends State<MessageCreator> {
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
  bool _isProcessingAudio = false;

  String amplitudePath = "";
  String filePath = "";
  String alteredAmplitudePath = "";
  String alteredFilePath = myAppStoragePath + "/tempFileAltered.aac";

  // 0 to 200
  double messageSpeed = 100;
  double messagePitch = 100;

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

  void _deleteEverything() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    if (File(amplitudePath).existsSync()) File(amplitudePath).deleteSync();
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    if (File(alteredAmplitudePath).existsSync())
      File(alteredAmplitudePath).deleteSync();
  }

  void startRecorder() async {
    _deleteEverything();
    try {
      this.filePath = await flutterSound.startRecorder(
          iosQuality: IosQuality.MAX, sampleRate: 44100, bitRate: 192000);
      print('start message recorder: $filePath');

      _recorderSubscription =
          flutterSound.onRecorderStateChanged.listen((e) {});

      this.setState(() {
        this._isRecording = true;
        this._hasShifted = false;
        this.messageSpeed = 100;
        this.messagePitch = 100;
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
    } catch (err) {
      print('stopRecorder error: $err');
    }
    // await _trimSilence();
    amplitudePath = await AmplitudeExtractor.createAmplitudeFile(filePath);
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

  Future<void> generateAlteredAudioFiles() async {
    if (File(alteredFilePath).existsSync()) File(alteredFilePath).deleteSync();
    if (File(alteredAmplitudePath).existsSync())
      File(alteredAmplitudePath).deleteSync();
    double pitchChange = (messagePitch / 100);
    double speedChange = (messageSpeed / 100);

    if (pitchChange < .5) pitchChange = .5;
    if (speedChange < .5) speedChange = .5;

    await FFMpeg.converter.execute(
        '-i $filePath -filter:a "asetrate=44100*$pitchChange,aresample=44100,atempo=$speedChange" -vn $alteredFilePath');
    alteredAmplitudePath =
        await AmplitudeExtractor.createAmplitudeFile(alteredFilePath);
    setState(() => _isProcessingAudio = false);
  }

  _trimSilence() async {
    Map info = await FFMpeg.probe.getMediaInformation(filePath);
    print(
        "info on alteredFilepath: ${await FFMpeg.probe.getMediaInformation(filePath)}");

    String duration = info["duration"].toString();
    print("Duration: $duration");
    await FFMpeg.converter.execute(
        '-i $filePath -filter:a "silenceremove=start_periods=1:start_duration=1:start_threshold=0dB:detection=peak,aformat=dblp,areverse,silenceremove=start_periods=1:start_duration=1:start_threshold=0dB:detection=peak,aformat=dblp,areverse" $alteredFilePath');
    // '-i $filePath -filter:a "silenceremove=start_periods=1:start_duration=0:start_threshold=0dB:detection=peak:stop_periods=0:stop_duration=0:stop_threshold=0dB:detection=peak:stop_silence=0" $alteredFilePath');
    File(filePath).deleteSync();
    File(alteredFilePath).renameSync(filePath);
    print("Altered filepath exists: ${File(alteredFilePath).existsSync()}");
    print("filepath exists: ${File(filePath).existsSync()}");
  }

  String resultPath() {
    if (File(alteredFilePath).existsSync()) {
      return alteredFilePath;
    } else {
      return filePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: messagePitch,
                  min: 0,
                  max: 200,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  onChanged: _isProcessingAudio || !_messageExists || _isRecording
                      ? null
                      : (value) {
                          setState(() {
                            messagePitch = value;
                            _hasShifted = true;
                          });
                        },
                  onChangeEnd: (value) async {
                    setState(() {
                      messagePitch = value;
                      _isProcessingAudio = true;
                    });
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
                            : _messageExists ? Colors.blue[100] : Colors.blue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        color: Colors.black38,
                        icon: _isProcessingAudio
                            ? SpinKitWave(
                                color: Colors.white,
                                size: 20,
                              )
                            : Icon(Icons.mic),
                        iconSize: 50,
                        onPressed: onStartRecorderPressed(),
                      ),
                    ),
                    Ink(
                      height: 80,
                      width: 80,
                      decoration: ShapeDecoration(
                        color: (_isRecording ||
                                !_messageExists ||
                                _isProcessingAudio)
                            ? Colors.grey[350]
                            : Colors.blue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        disabledColor: Colors.grey,
                        color: !_messageExists ? Colors.grey : Colors.black38,
                        icon: _isPlaying
                            ? Icon(Icons.stop)
                            : Icon(Icons.play_arrow),
                        iconSize: 50,
                        onPressed: _isRecording ||
                                !_messageExists ||
                                _isProcessingAudio
                            ? null
                            : handlePlayStopButton,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Text(
                        "Next Step ->",
                        style: TextStyle(color: Colors.blue, fontSize: 30),
                      ),
                      onTap: () async {
                        widget.updateMessageFilePathCallback(resultPath());
                      },
                    ),
                    Divider(),
                    GestureDetector(
                      child: Text(
                        "Skip ->",
                        style: TextStyle(color: Colors.amber, fontSize: 30),
                      ),
                      onTap: () {
                        widget.updateMessageFilePathCallback();
                      },
                    ),
                  ],
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: messageSpeed,
                  min: 0,
                  max: 200,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  onChanged: _isProcessingAudio || !_messageExists || _isRecording
                      ? null
                      : (value) async {
                          setState(() {
                            messageSpeed = value;
                            _hasShifted = true;
                          });
                        },
                  onChangeEnd: (value) {
                    setState(() {
                      messageSpeed = value;
                      _isProcessingAudio = true;
                    });
                    generateAlteredAudioFiles();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
