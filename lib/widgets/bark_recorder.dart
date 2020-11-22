import 'dart:async';
import 'dart:io';

import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/spinner_half_screen_widget.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound_lite/flutter_sound.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
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
  double maxDuration = 1.0;
  Timer _recordingTimer;
  KaraokeCard card;
  Barks barks;
  CurrentActivity currentActivity;
  AnimationController _animationController;
  Animation _animation;
  bool _loading = false;

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
    barks.deleteTempRawBark();
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
    setState(() => _loading = true);
    await barks.uploadRawBarkAndRetrieveCroppedBarks(card.picture.fileId);
    setState(() => _loading = false);
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
    return _loading || soundController.player.isPlaying;
  }

  void _handleUploadVideoButton() async {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            header: "Upload Video",
            bodyText:
                "We'll take the first 15 seconds of sounds and convert them into separate barks.",
            primaryFunction: (BuildContext modalContext) {
              Navigator.of(modalContext).pop();
              _handleUploadVideo();
            },
            secondaryFunction: (BuildContext modalContext) async {
              Navigator.of(modalContext).pop();
            },
            iconPrimary: Icon(
              Icons.movie,
              size: 42,
              color: Colors.grey[300],
            ),
            iconSecondary: Icon(
              CustomIcons.modal_paws_topleft,
              size: 42,
              color: Colors.grey[300],
            ),
            isYesNo: false,
            primaryButtonText: "Pick Video",
            secondaryButtonText: "Back",
          );
        });
  }

  void _handleUploadVideo() async {
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted) {
      showError(context, "Gallary permission not granted");
      return;
    }
    final pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;
    barks.deleteTempRawBark();
    await FFMpeg.process.execute(
        '-i ${pickedFile.path} -ss 00:00:00 -t 15 -vn -ar 44100 -ac 1 $filePath');
    await barks.setTempRawBark(Bark(filePath: filePath));
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context);
    soundController = Provider.of<SoundController>(context);
    barks = Provider.of<Barks>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    filePath = '$myAppStoragePath/tempRaw.aac';

    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InterfaceTitleNav('CAPTURE BARKS',
              backCallback: _backCallback, skipCallback: _skipCallback),
          _loading
              ? SpinnerHalfScreenWidget("Processing Barks...")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 130,
                          width: 150,
                          child: Column(
                            children: <Widget>[
                              RawMaterialButton(
                                onPressed:
                                    _loading || soundController.player.isPlaying
                                        ? null
                                        : onStartRecorderPressed,
                                child: _loading
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
                                      fontSize: 16,
                                      color: Theme.of(context).errorColor))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 130,
                          width: 140,
                          child: Column(
                            children: <Widget>[
                              RawMaterialButton(
                                constraints: const BoxConstraints(
                                    minWidth: 70.0, minHeight: 36.0),
                                onPressed: _systemBusy()
                                    ? null
                                    : _handleUploadVideoButton,
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
                              Text("UPLOAD AUDIO\nFROM VIDEO",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor))
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ADD BARKS BUTTON
                    if (barks.tempRawBark == null)
                      Center(
                        child: Text(
                          "Press 'skip' to use Stock Barks and FX",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (barks.tempRawBark != null && !_isRecording)
                      // maintainState: true,
                      // maintainAnimation: true,
                      // maintainSize: true,

                      GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          await barks.uploadRawBarkAndRetrieveCroppedBarks(
                              cards.current.picture.fileId);
                          setState(() => _loading = false);
                          currentActivity
                              .setCardCreationSubStep(CardCreationSubSteps.two);
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
                  ],
                ),
          Padding(
            padding: EdgeInsets.all(5),
          )
        ],
      ),
    );
  }
}
