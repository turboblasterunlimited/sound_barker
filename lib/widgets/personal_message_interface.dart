import 'package:K9_Karaoke/animations/waggle.dart';
import 'package:K9_Karaoke/classes/card_message.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/screens/cart_type_screen.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'dart:async';

import '../providers/sound_controller.dart';
import '../tools/amplitude_extractor.dart';

// cardCreationSubStep.seven
class PersonalMessageInterface extends StatefulWidget {
  @override
  PersonalMessageInterfaceState createState() =>
      PersonalMessageInterfaceState();
}

class PersonalMessageInterfaceState extends State<PersonalMessageInterface> {
  StreamSubscription _recorderSubscription;
  SoundController soundController;
  bool _isRecording = false;
  bool _hasShifted = false;
  bool _isProcessingAudio = false;

  // .5 to 2
  double speedChange = 1;
  double pitchChange = 1;

  CurrentActivity currentActivity;
  KaraokeCards cards;
  CardMessage message;
  ImageController imageController;
  Timer _recordingTimer;

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

  bool _isLoading = false;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _recordSound() {
    soundController.record(message.filePath);
    _recordingTimer = Timer(Duration(seconds: 25), () {
      stopRecorder();
      soundController.startPlayer("assets/sounds/bell.aac", asset: true);
    });
    this.setState(() {
      this._isRecording = true;
      this._hasShifted = false;
      this.speedChange = 1;
      this.pitchChange = 1;
    });
  }

  void startRecorder() async {
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      showError(context, "Accept microphone permisions to record");
      return;
    }

    message.deleteEverything();
    print("message filepath: ${message.filePath}");
    await soundController.startPlayer("assets/sounds/beeoop.aac",
        asset: true, stopCallback: _recordSound);
  }

  void stopRecorder() async {
    _recordingTimer.cancel();

    setState(() {
      this._isRecording = false;
    });

    await soundController.stopRecording();
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
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
    // Directory tempDir = await getTemporaryDirectory();
    // message.filePath = '${tempDir.path}/card_message.aac';
    // message.alteredFilePath = '${tempDir.path}/altered_card_message.aac';
    message.filePath = '$myAppStoragePath/card_message.aac';
    message.alteredFilePath = '$myAppStoragePath/altered_card_message.aac';
  }

  Future<void> generateAlteredAudioFiles() async {
    message.deleteAlteredFiles();

    await FFMpeg.process.execute(
        '-i ${message.filePath} -filter_complex "asetrate=44100*$pitchChange,aresample=44100,atempo=$speedChange${effects[selectedEffect]}" -vn ${message.alteredFilePath}');
    message.alteredAmplitudes =
        await AmplitudeExtractor.getAmplitudes(message.alteredFilePath);
    setState(() => _isProcessingAudio = false);
    cards.messageIsReady();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  void backCallback() {
    if (cards.current.hasASongFormula)
      currentActivity.setPreviousSubStep();
    else
      currentActivity.setCardCreationStep(CardCreationSteps.song);
    if (currentActivity.cardType == CardType.justMessage)
      Navigator.pushNamed(context, CardTypeScreen.routeName);
  }

  void skipCallback() async {
    // first time creation: audio and oldCardAudio are null. If new song is selected: audio is set to oldCardAudio
    // if (cards.current.oldCardAudio == cards.current.audio &&
    //     cards.current.hasASong) {
    if (cards.current.hasASong) {
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
      speedChange = 1;
      pitchChange = 1;
      effectSliderVal = 0.0;
    });
    message.deleteAlteredFiles();
  }

  void _handleCombineAndContinue() async {
    setState(() => _isLoading = true);
    await cards.current.combineMessageAndSong();
    setState(() => _isLoading = false);
    currentActivity.setCardCreationStep(CardCreationSteps.style);
  }

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context, listen: false);
    soundController = Provider.of<SoundController>(context);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    cards = Provider.of<KaraokeCards>(context, listen: false);
    message = cards.current.message;
    _createFilePaths();

    return Column(
      children: <Widget>[
        InterfaceTitleNav(
            title: cards.current.hasASong ? "PRE-SONG MESSAGE" : "CARD MESSAGE",
            backCallback: backCallback,
            skipCallback: skipCallback),
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
                      onPressed: _isLoading || soundController.player.isPlaying
                          ? null
                          : onStartRecorderPressed,
                      child: _isLoading
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
                height: 72,
                width: 150,
                child: !_canAddMessage()
                    ? Text(
                        cards.current.hasASong
                            ? "RECORD A HUMAN-VOICE INTRODUCTION TO YOUR SONG."
                            : "RECORD YOUR HUMAN-VOICE AUDIO GREETING.",
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : GestureDetector(
                        onTap: _handleCombineAndContinue,
                        child: Waggle(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).primaryColor),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
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
        Visibility(
          visible: message.exists,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Padding(
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
                        label: "${pitchChange.toStringAsFixed(1)} X",
                        value: pitchChange,
                        divisions: 15,
                        min: 0.5,
                        max: 2,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: _isProcessingAudio || _isRecording
                            ? null
                            : (value) {
                                soundController.stopPlayer();
                                imageController.stopAnimation();
                                setState(() {
                                  pitchChange = value;
                                  _hasShifted = true;
                                });
                              },
                        onChangeEnd: (value) async {
                          setState(() {
                            pitchChange = value;
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
                        label: "${speedChange.toStringAsFixed(1)} X",
                        value: speedChange,
                        divisions: 15,
                        min: 0.5,
                        max: 2,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        onChanged: _isProcessingAudio || _isRecording
                            ? null
                            : (value) async {
                                soundController.stopPlayer();
                                imageController.stopAnimation();
                                setState(() {
                                  speedChange = value;
                                  _hasShifted = true;
                                });
                              },
                        onChangeEnd: (value) {
                          setState(() {
                            speedChange = value;
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: effectSliderVal,
                        divisions: effects.length - 1,
                        min: 0,
                        max: effects.length.toDouble() - 1,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                        label: selectedEffect,
                        onChanged: _isProcessingAudio ||
                                !message.exists ||
                                _isRecording
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
        ),
        message.exists
            ? Visibility(
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
                      side: BorderSide(
                          color: Theme.of(context).primaryColor, width: 3),
                    ),
                    elevation: 5,
                    // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
                  ),
                ),
              )
            : Text(
                "MESSAGE CANNOT\nEXCEED 25-SECONDS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              )
      ],
    );
  }
}
