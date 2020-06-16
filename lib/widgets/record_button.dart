import 'package:K9_Karaoke/providers/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  SoundController soundController;
  SpinnerState spinnerState;
  double maxDuration = 1.0;
  Timer _recordingTimer;

  @override
  void initState() {
    super.initState();
  }

  void startRecorder() async {
    Directory tempDir = await getTemporaryDirectory();
    this.filePath =
        '${tempDir.path}/${soundController.recorder.slotNo}-flutter_sound.aac}';
    PermissionStatus status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }

    try {
      await soundController.recorder.startRecorder(
          toFile: this.filePath, sampleRate: 44100, bitRate: 192000);
      _recordingTimer = Timer(Duration(seconds: 10), stopRecorder);

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
      await soundController.recorder.stopRecorder();
    } catch (err) {
      print('stopRecorder error: $err');
    }

    Bark rawBark = Bark(filePath: filePath);
    Pictures pictures = Provider.of<Pictures>(context, listen: false);
    List croppedBarks = await rawBark
        .uploadBarkAndRetrieveCroppedBarks(pictures.mountedPictureFileId());
    Barks barks = Provider.of<Barks>(context, listen: false);
    addCroppedBarksToAllBarks(barks, croppedBarks);
    await barks.downloadAllBarksFromBucket(croppedBarks);
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
    if (soundController.recorder.isRecording) return stopRecorder;
    return startRecorder;
  }

  @override
  Widget build(BuildContext context) {
    soundController = Provider.of<SoundController>(context, listen: true);
    spinnerState = Provider.of<SpinnerState>(context, listen: true);
    return RawMaterialButton(
      onPressed: spinnerState.barksLoading ? null : onStartRecorderPressed(),
      child: spinnerState.barksLoading
          ? SpinKitWave(
              color: Colors.white,
              size: 20,
            )
          : Text(
              this._isRecording
                  ? "RECORDING... TAP TO STOP"
                  : "TAP TO RECORD BARKS",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
        // side: BorderSide(color: Colors.red),
      ),
      elevation: 2.0,
      fillColor: this._isRecording
          ? Colors.redAccent[200]
          : Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
    );
  }
}
