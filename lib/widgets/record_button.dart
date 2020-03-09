import 'package:flutter/material.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

import '../providers/barks.dart';

// enum t_MEDIA {
//   FILE,
//   BUFFER,
//   ASSET,
//   STREAM,
// }

class RecordButton extends StatefulWidget {
  static const routeName = 'bark-screen';

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  String filePath;
  bool _isRecording = false;
  // List<String> _path = [null, null, null, null, null, null, null];
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  // t_MEDIA _media = t_MEDIA.FILE;
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
  }

  void startRecorder() async {
    try {
      this.filePath = await flutterSound.startRecorder(
        codec: _codec,
        iosQuality: IosQuality.HIGH
      );
      //print('startRecorder: $filePath');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
        // this._path[_codec.index] = filePath;
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
    String imageName;

    try {
      String result = await flutterSound.stopRecorder();
      //print('stopRecorder: $result');
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (err) {
      //print('stopRecorder error: $err');
    }
    
  

    Bark rawBark = Bark(name: imageName, filePath: filePath);
    List croppedBarks = await rawBark.uploadBarkAndRetrieveCroppedBarks();
    //print("Upload and Retrieve Cropped Barks checkpoint");
    Barks barks = Provider.of<Barks>(context, listen: false);
    addCroppedBarksToAllBarks(barks, croppedBarks);
    barks.downloadAllBarksFromBucket(croppedBarks);
  }

  void addCroppedBarksToAllBarks(allBarks, croppedBarks) {
    int length = croppedBarks.length;
    for (var i = 0; i < length; i++) {
      setState(() {
        allBarks.addBark(croppedBarks[i]);
      });
    }
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  onStartRecorderPressed() {
    // if (_media == t_MEDIA.ASSET || _media == t_MEDIA.BUFFER) return null;
    if (flutterSound.audioState == t_AUDIO_STATE.IS_RECORDING)
      return stopRecorder;

    return flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startRecorder
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onStartRecorderPressed(),
      child: Icon(
        Icons.mic,
        color: Colors.black38,
        size: 40,
      ),
      shape: CircleBorder(),
      elevation: 2.0,
      fillColor: this._isRecording ? Colors.redAccent[200] : Colors.white,
      padding: const EdgeInsets.all(15.0),
    );
  }
}
