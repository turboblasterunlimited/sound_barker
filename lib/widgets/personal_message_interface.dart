import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/providers/spinner_state.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
class PersonalMessageInterface extends StatefulWidget {
  @override
  PersonalMessageInterfaceState createState() =>
      PersonalMessageInterfaceState();
}

class PersonalMessageInterfaceState extends State<PersonalMessageInterface>
    with TickerProviderStateMixin {
  StreamSubscription _recorderSubscription;
  SoundController soundController;
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

  Map<String, String> effects = {
    'None': "",
    'Chorus': ',aecho=0.8:0.88:60:0.4',
    'Echo': ',aecho=0.8:0.9:1000|1800:0.3|0.25',
    'Robot':
        ",afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=512:overlap=0.75",
    'Reverse': ',areverse',
    'Tremolo': ',tremolo=f=10:d=1',
  };

  double effectSliderVal = 0.0;

  String get selectedEffect {
    return effects.keys.toList()[effectSliderVal.round()];
  }

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
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      showError(context, "Accept microphone permisions to record");
      return;
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
        '-i ${message.filePath} -filter_complex "asetrate=44100*$pitchChange,aresample=44100,atempo=$speedChange${effects[selectedEffect]}" -vn ${message.alteredFilePath}');
    print("site of error");
    message.alteredAmplitudes =
        await AmplitudeExtractor.getAmplitudes(message.alteredFilePath);
    setState(() => _isProcessingAudio = false);
    cards.messageIsReady();
  }

  void backCallback() {
    if (cards.current.hasSongFormula)
      currentActivity.setPreviousSubStep();
    else
      currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  void skipCallback() async {
    // first time creation: audio and oldCardAudio are null. If new song is selected: audio is set to oldCardAudio
    if (cards.current.oldCardAudio == cards.current.audio &&
        cards.current.hasSong) {
      await cards.current.songToAudio();
      return currentActivity.setCardCreationStep(CardCreationSteps.style);
      // already created audio but going back through and just clicking skip without having changed the song
    } else if (cards.current.hasAudio) {
      return currentActivity.setCardCreationStep(CardCreationSteps.style);
    } else {
      showError(context, "Need a song or a message or both!");
      return null;
    }
  }

  bool _canAddMessage() {
    return message.exists && !_isRecording;
  }

  void _resetSliders() {
    setState(() {
      messageSpeed = 100;
      messagePitch = 100;
      effectSliderVal = 0.0;
    });
    message.deleteAlteredFiles();
  }

  void _handleCombineAndContinue() async {
    spinnerState.startLoading();
    await cards.current.combineMessageAndSong();
    spinnerState.stopLoading();
    currentActivity.setCardCreationStep(CardCreationSteps.style);
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
      children: <Widget>[
        interfaceTitleNav(context, "PERSONAL MESSAGE",
            backCallback: backCallback, skipCallback: skipCallback),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: SizedBox(
                height: 110,
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
                              size: 25,
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
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: 60,
                width: 150,
                child: !_canAddMessage()
                    ? Center()
                    : GestureDetector(
                        onTap: _handleCombineAndContinue,
                        child: Transform.rotate(
                          angle: _canAddMessage() ? _animation.value * 0.1 : 0,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).primaryColor),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                "ADD MESSAGE\nAND CONTINUE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text("Pitch",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Text("Speed",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Text(
                      "Effect",
                      // selectedEffect,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: effectSliderVal,
                      divisions: effects.length - 1,
                      min: 0,
                      max: effects.length.toDouble() - 1,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey,
                      label: selectedEffect,
                      onChanged:
                          _isProcessingAudio || !message.exists || _isRecording
                              ? null
                              : (value) async {
                                  soundController.stopPlayer();
                                  imageController.stopAnimation();
                                  setState(() {
                                    effectSliderVal = value;
                                    _hasShifted = true;
                                  });
                                },
                      onChangeEnd: (value) {
                        setState(() {
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
        ),
        Visibility(
          visible: _hasShifted,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Center(
            child: RawMaterialButton(
              onPressed: _resetSliders,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "reset sliders",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side:
                    BorderSide(color: Theme.of(context).primaryColor, width: 3),
              ),
              elevation: 5,
              // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
            ),
          ),
        )
      ],
    );
  }
}
