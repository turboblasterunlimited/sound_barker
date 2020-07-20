import 'dart:async';
import 'dart:io';

import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkRecorder extends StatefulWidget {
  @override
  BarkRecorderState createState() => BarkRecorderState();
}

class BarkRecorderState extends State<BarkRecorder> {
  KaraokeCards cards;
  String filePath;
  bool _isRecording = false;
  SoundController soundController;
  SpinnerState spinnerState;
  double maxDuration = 1.0;
  Timer _recordingTimer;
  KaraokeCard card;
  Barks barks;

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
    setState(() {
      this._isRecording = false;
    });
    try {
      await soundController.recorder.stopRecorder();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    barks.setTempRawBark(Bark(filePath: filePath));
  }

  void addCroppedBarksToAllBarks(Barks barks, croppedBarks) async {
    spinnerState.loadBarks();
    await barks.uploadRawBarkAndRetrieveCroppedBarks(card.picture.fileId);
    spinnerState.stopLoading();
  }

  onStartRecorderPressed() {
    return soundController.recorder.isRecording ? stopRecorder : startRecorder;
  }

  @override
  Widget build(BuildContext context) {
    final cards = Provider.of<KaraokeCards>(context);
    final soundController = Provider.of<SoundController>(context);
    final barks = Provider.of<Barks>(context, listen: false);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: RawMaterialButton(
                onPressed:
                    spinnerState.barksLoading ? null : onStartRecorderPressed(),
                child: spinnerState.barksLoading
                    ? SpinKitWave(
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        _isRecording
                            ? "RECORDING... TAP TO STOP"
                            : "RECORD BARKS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: _isRecording
                      ? BorderRadius.circular(1.0)
                      : BorderRadius.circular(40.0),
                  // side: BorderSide(color: Colors.red),
                ),
                elevation: 2.0,
                fillColor: _isRecording
                    ? Theme.of(context).errorColor
                    : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(Icons.music_note),
                onPressed: () {
                  // cards
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}