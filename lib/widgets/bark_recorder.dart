import 'dart:async';

import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound_lite/flutter_sound.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';
import '../providers/sound_controller.dart';

class BarkRecorder extends StatefulWidget {
  @override
  BarkRecorderState createState() => BarkRecorderState();
}

class BarkRecorderState extends State<BarkRecorder>
    with TickerProviderStateMixin {
  KaraokeCards cards;
  String filePath;
  bool _isRecording = false;
  SoundController soundController;
  SpinnerState spinnerState;
  double maxDuration = 1.0;
  Timer _recordingTimer;
  KaraokeCard card;
  Barks barks;
  CurrentActivity currentActivity;
  AnimationController _animationController;
  Animation _animation;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation =
        CurveTween(curve: Curves.elasticIn).animate(_animationController)
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  void _recordSound() {
    soundController.record(this.filePath);
    _recordingTimer = Timer(Duration(seconds: 10), () {
      soundController.startPlayer("assets/sounds/bell.aac", asset: true);
      stopRecorder();
    });
    this.setState(() {
      this._isRecording = true;
    });
  }

  void startRecorder() async {
    // Directory tempDir = await getTemporaryDirectory();
    this.filePath = '$myAppStoragePath/tempRaw.aac';

    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      showError(context, "Microphone permission not granted");
      return;
    }

    await soundController.startPlayer("assets/sounds/ding.aac",
        asset: true, stopCallback: _recordSound);
  }

  void stopRecorder() async {
    _recordingTimer.cancel();

    setState(() {
      this._isRecording = false;
    });

    await soundController.stopRecording();
    await barks.setTempRawBark(Bark(filePath: filePath));
  }

  void addCroppedBarksToAllBarks(Barks barks, croppedBarks) async {
    spinnerState.startLoading();
    await barks.uploadRawBarkAndRetrieveCroppedBarks(card.picture.fileId);
    spinnerState.stopLoading();
  }

  onStartRecorderPressed() {
    print("recorder pressed");
    soundController.recorder.isRecording ? stopRecorder() : startRecorder();
  }

  void _backCallback() {
    currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  void _skipCallback() {
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
  }

  bool _systemBusy() {
    return spinnerState.isLoading || soundController.player.isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context);
    soundController = Provider.of<SoundController>(context);
    barks = Provider.of<Barks>(context, listen: false);
    spinnerState = Provider.of<SpinnerState>(context);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InterfaceTitleNav('CAPTURE BARKS',
            backCallback: _backCallback, skipCallback: _skipCallback),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 130,
              width: 150,
              child: Column(
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: spinnerState.isLoading ||
                            soundController.player.isPlaying
                        ? null
                        : onStartRecorderPressed,
                    child: spinnerState.isLoading
                        ? SpinKitWave(
                            color: Colors.white,
                            size: 20,
                          )
                        : Icon(
                            _isRecording
                                ? Icons.stop
                                : Icons.fiber_manual_record,
                            size: 30,
                            color: Colors.white,
                          ),
                    shape: _isRecording
                        ? RoundedRectangleBorder()
                        : CircleBorder(),
                    elevation: 2.0,
                    fillColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.all(20.0),
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  Text(
                      _isRecording
                          ? "RECORDING...\nTAP TO STOP"
                          : "RECORD AUDIO",
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).errorColor))
                ],
              ),
            ),
            SizedBox(
              height: 130,
              width: 140,
              child: Column(
                children: <Widget>[
                  RawMaterialButton(
                    constraints:
                        const BoxConstraints(minWidth: 70.0, minHeight: 36.0),
                    onPressed: _systemBusy() ? null : null,
                    child: Icon(
                      Icons.movie,
                      size: 30,
                      color: Colors.white,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(20.0),
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  Text("UPLOAD VIDEO",
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          ],
        ),
        // ADD BARKS BUTTON

        Visibility(
          visible: barks.tempRawBark != null && !_isRecording,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: GestureDetector(
            onTap: () async {
              spinnerState.startLoading("Processing barks...");
              await barks.uploadRawBarkAndRetrieveCroppedBarks(
                  cards.current.picture.fileId);
              spinnerState.stopLoading();
              currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
            },
            child: Transform.rotate(
              angle: _animation.value * 0.1,
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).primaryColor,
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.green,
                  //       blurRadius: _animation.value,
                  //       spreadRadius: _animation.value)
                  // ]
                ),
                child: Text(
                  "ADD BARKS\nAND CONTINUE",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5),
        )
      ],
    );
  }
}
