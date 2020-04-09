import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/image_controller.dart';
import '../providers/pictures.dart';

import './generate_card_screen.dart';

enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
}

class RecordMessageScreen extends StatefulWidget {
  static const routeName = 'record-message-screen';
  String songId;
  String pictureId;

  RecordMessageScreen(this.songId, this.pictureId);

  @override
  _RecordMessageScreenState createState() => _RecordMessageScreenState();
}

class _RecordMessageScreenState extends State<RecordMessageScreen> {
  bool _isRecording = false;
  String filePath;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  t_CODEC _codec = t_CODEC.CODEC_AAC;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
  }

  void startRecorder() async {
    try {
      this.filePath = await flutterSound.startRecorder(
          codec: _codec, iosQuality: IosQuality.HIGH);
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
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  onStartRecorderPressed() {
    if (flutterSound.audioState == t_AUDIO_STATE.IS_RECORDING)
      return stopRecorder;

    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startRecorder
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Record a personal message?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Ink(
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
                      "Skip ->",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    onTap: () {
                      final pictures = Provider.of<Pictures>(context, listen: false);
                      final picture = pictures.findById(widget.pictureId);
                      pictures.mountPicture(picture);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GenerateCardScreen(widget.songId),
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
