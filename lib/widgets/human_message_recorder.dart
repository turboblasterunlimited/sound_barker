import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'dart:async';
import 'dart:io';

import '../providers/sound_controller.dart';
import '../tools/amplitude_extractor.dart';

// cardCreationSubStep.seven
class HumanMessageRecorder extends StatefulWidget {
  @override
  HumanMessageRecorderState createState() => HumanMessageRecorderState();
}

class HumanMessageRecorderState extends State<HumanMessageRecorder>
    with TickerProviderStateMixin {
  StreamSubscription _recorderSubscription;
  SoundController soundController;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _hasShifted = false;
  bool _isProcessingAudio = false;

  // 0 to 200
  double messageSpeed = 100;
  double messagePitch = 100;

  CurrentActivity currentActivity;
  SpinnerState spinnerState;
  KaraokeCards cards;
  CardMessage message;
  AnimationController _animationController;
  Animation _animation;
  ImageController imageController;

  @override
  void dispose() {
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

  void startRecorder() async {
    print("in start recorder.");
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }

    message.deleteEverything();

    try {
      await soundController.recorder.startRecorder(
          toFile: message.filePath, sampleRate: 44100, bitRate: 192000);

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
    });

    try {
      await soundController.recorder.stopRecorder();
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }
    message.amplitudes =
        await AmplitudeExtractor.getAmplitudes(message.filePath);
    cards.messageIsReady();
  }

  onStartRecorderPressed() {
    print("start recorder pressed.");
    if (soundController.recorder.isRecording) return stopRecorder();
    return startRecorder();
  }

  void _createFilePaths() async {
    Directory tempDir = await getTemporaryDirectory();
    message.filePath = '${tempDir.path}/card_message.aac';
    message.alteredFilePath = '${tempDir.path}/altered_card_message.aac';
  }

  Future<void> generateAlteredAudioFiles() async {
    message.deleteAlteredFiles();
    double pitchChange = (messagePitch / 100);
    double speedChange = (messageSpeed / 100);

    if (pitchChange < .5) pitchChange = .5;
    if (speedChange < .5) speedChange = .5;

    await FFMpeg.process.execute(
        '-i ${message.filePath} -filter:a "asetrate=44100*$pitchChange,aresample=44100,atempo=$speedChange" -vn ${message.alteredFilePath}');
    print("site of error");
    message.alteredAmplitudes =
        await AmplitudeExtractor.getAmplitudes(message.alteredFilePath);
    setState(() => _isProcessingAudio = false);
    cards.messageIsReady();
  }

  Widget backSkipBar() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (cards.current.hasSongFormula)
                    currentActivity.setPreviousSubStep();
                  else
                    currentActivity.setCardCreationStep(CardCreationSteps.song);
                },
                child: Row(children: <Widget>[
                  Icon(LineAwesomeIcons.angle_left),
                  Text('Back'),
                ]),
              ),
              Center(
                child: Text("PERSONAL MESSAGE",
                    style: TextStyle(
                        fontSize: 17, color: Theme.of(context).primaryColor)),
              ),
              Positioned(
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    currentActivity.setNextSubStep();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(LineAwesomeIcons.angle_right),
                      Text('Skip'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _canAddMessage() {
    return message.exists && !_isRecording;
  }

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context, listen: false);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    spinnerState = Provider.of<SpinnerState>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    message = cards.current.message;

    _createFilePaths();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        backSkipBar(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: SizedBox(
                height: 120,
                width: 120,
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
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      _isRecording ? "RECORDING...  \nTAP TO STOP" : "RECORD",
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).errorColor),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 80,
              width: 150,
              child: !_canAddMessage()
                  ? Center()
                  : GestureDetector(
                      onTap: () async {
                        spinnerState.startLoading();
                        await cards.current.combineMessageAndSong();
                        spinnerState.stopLoading();
                        currentActivity
                            .setCardCreationStep(CardCreationSteps.style);
                      },
                      child: Transform.rotate(
                        angle: _canAddMessage() ? _animation.value * 0.1 : 0,
                        child: Container(
                          // margin: EdgeInsets.symmetric(horizontal: 24.0),
                          // padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).primaryColor),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              "ADD MESSAGE\nAND CONTINUE",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Text("Pitch",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Slider(
                    value: messagePitch,
                    min: 0,
                    max: 200,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged:
                        _isProcessingAudio || !message.exists || _isRecording
                            ? null
                            : (value) {
                                soundController.stopPlayer();
                                imageController.stopAnimation();
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
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Text("Speed",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Slider(
                    value: messageSpeed,
                    min: 0,
                    max: 200,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged:
                        _isProcessingAudio || !message.exists || _isRecording
                            ? null
                            : (value) async {
                                soundController.stopPlayer();
                                imageController.stopAnimation();
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
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Text("Effect",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Slider(
                    value: messageSpeed,
                    min: 0,
                    max: 200,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    onChanged: null,
                    // _isProcessingAudio || !message.exists || _isRecording
                    //     ? null
                    //     : (value) async {
                    //         soundController.stopPlayer();
                    //         imageController.stopAnimation();
                    //         setState(() {
                    //           messageSpeed = value;
                    //           _hasShifted = true;
                    //         });
                    //       },
                    onChangeEnd: (value) {
                      setState(() {
                        messageSpeed = value;
                        _isProcessingAudio = true;
                      });
                      generateAlteredAudioFiles();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
