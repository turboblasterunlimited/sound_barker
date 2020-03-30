import 'package:flutter/material.dart';
import 'package:flutter_sound/ios_quality.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';

import '../providers/barks.dart';
import '../providers/pictures.dart';
import '../providers/spinner_state.dart';

class RecordButton extends StatefulWidget {
  static const routeName = 'bark-screen';

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  String filePath;
  bool _isRecording = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;
  SpinnerState spinnerState;

  // String _recorderTxt = '00:00:00';
  // String _playerTxt = '00:00:00';
  // double _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  t_CODEC _codec = t_CODEC.CODEC_AAC;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    flutterSound.setDbPeakLevelUpdate(0.8);
    flutterSound.setDbLevelEnabled(true);
    initializeDateFormatting();
    spinnerState = Provider.of<SpinnerState>(context, listen: false);
  }

  void startRecorder() async {
    try {
      this.filePath = await flutterSound.startRecorder(
          codec: _codec, iosQuality: IosQuality.HIGH);
      //print('startRecorder: $filePath');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

        // setState(() {
        //   this._recorderTxt = txt.substring(0, 8);
        // });
      });
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        // setState(() {
        //   this._dbLevel = value;
        // });
      });

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
    spinnerState.loadBarks();
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

    Bark rawBark = Bark(filePath: filePath);
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    List croppedBarks = await rawBark
        .uploadBarkAndRetrieveCroppedBarks(pictures.mountedPictureFileId());
    Barks barks = Provider.of<Barks>(context, listen: false);
    addCroppedBarksToAllBarks(barks, croppedBarks);
    barks.downloadAllBarksFromBucket(croppedBarks);
    spinnerState.stopLoading();
  }

  void addCroppedBarksToAllBarks(Barks barks, croppedBarks) {
    int length = croppedBarks.length;
    for (var i = 0; i < length; i++) {
      barks.addBark(croppedBarks[i]);
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
