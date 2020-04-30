import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/ios_quality.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sound_lite/flutter_sound_recorder.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  FlutterSoundRecorder flutterSound;
  SpinnerState spinnerState;
  double maxDuration = 1.0;
  Timer _recordingTimer;

  @override
  void initState() {
    super.initState();
    flutterSound = FlutterSoundRecorder();
  }

  void startRecorder() async {
    try {
      this.filePath = await flutterSound.startRecorder(
          iosQuality: IosQuality.MAX,
          sampleRate: 44100,
          bitRate: 192000);
      _recordingTimer = Timer(Duration(seconds: 10), () {
        stopRecorder();
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
    _recordingTimer.cancel();
    spinnerState.loadBarks();
    setState(() {
      this._isRecording = false;
    });
    try {
      await flutterSound.stopRecorder();
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
    if (flutterSound.isRecording) return stopRecorder;
    return startRecorder;
  }

  @override
  Widget build(BuildContext context) {
    spinnerState = Provider.of<SpinnerState>(context, listen: true);

    return RawMaterialButton(
      onPressed: spinnerState.barksLoading ? null : onStartRecorderPressed(),
      child: spinnerState.barksLoading
          ? SpinKitWave(
              color: Theme.of(context).primaryColor,
              size: 20,
            )
          : Text(
              this._isRecording
                  ? "RECORDING... TAP TO STOP"
                  : "TAP TO RECORD SOUNDS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        // side: BorderSide(color: Colors.red),
      ),
      elevation: 2.0,
      fillColor: this._isRecording ? Colors.redAccent[200] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
    );
  }
}
