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
  bool _messageExists = false;
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
      this._messageExists = true;
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

  // _trimSilence() async {
  //   Map info = await FFMpeg.probe.getMediaInformation(filePath);
  //   print(
  //       "info on alteredFilepath: ${await FFMpeg.probe.getMediaInformation(filePath)}");

  //   String duration = info["duration"].toString();
  //   print("Duration: $duration");
  //   await FFMpeg.process.execute(
  //       '-i $filePath -filter:a "silenceremove=start_periods=1:start_duration=1:start_threshold=0dB:detection=peak,aformat=dblp,areverse,silenceremove=start_periods=1:start_duration=1:start_threshold=0dB:detection=peak,aformat=dblp,areverse" $alteredFilePath');
  //   // '-i $filePath -filter:a "silenceremove=start_periods=1:start_duration=0:start_threshold=0dB:detection=peak:stop_periods=0:stop_duration=0:stop_threshold=0dB:detection=peak:stop_silence=0" $alteredFilePath');
  //   File(filePath).deleteSync();
  //   File(alteredFilePath).renameSync(filePath);
  //   print("Altered filepath exists: ${File(alteredFilePath).existsSync()}");
  //   print("filepath exists: ${File(filePath).existsSync()}");
  // }

  // pitched/stretched recroding or unaltered recording

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
                child: Text("RECORD HUMAN MESSAGE",
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).primaryColor)),
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
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            RawMaterialButton(
              onPressed:
                  spinnerState.isLoading || soundController.player.isPlaying
                      ? null
                      : onStartRecorderPressed,
              child: spinnerState.isLoading
                  ? SpinKitWave(
                      color: Colors.white,
                      size: 20,
                    )
                  : Icon(
                      _isRecording ? Icons.stop : Icons.fiber_manual_record,
                      size: 30,
                      color: Colors.white,
                    ),
              shape: _isRecording ? RoundedRectangleBorder() : CircleBorder(),
              elevation: 2.0,
              fillColor: Theme.of(context).errorColor,
              padding: const EdgeInsets.all(20.0),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
            Text(
              _isRecording ? "RECORDING...  \nTAP TO STOP" : "",
              style:
                  TextStyle(fontSize: 16, color: Theme.of(context).errorColor),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 150,
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
                        _isProcessingAudio || !_messageExists || _isRecording
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
            SizedBox(
              width: 150,
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
                        _isProcessingAudio || !_messageExists || _isRecording
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
          ],
        ),
        _messageExists && !_isRecording
            ? GestureDetector(
                onTap: () async {
                  spinnerState.startLoading();
                  await cards.current.combineMessageAndSong();
                  spinnerState.stopLoading();
                  currentActivity.setCardCreationStep(CardCreationSteps.style);
                },
                child: Transform.rotate(
                  angle: _animation.value * 0.1,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.rectangle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      "ADD MESSAGE\nAND CONTINUE",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : Center(),
      ],
    );
  }
}
