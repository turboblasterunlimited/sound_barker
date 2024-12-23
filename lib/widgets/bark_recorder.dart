import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:K9_Karaoke/animations/waggle.dart';
import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/karaoke_cards.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/loading_half_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/barks.dart';
import '../providers/flutter_sound_controller.dart';
import '../providers/the_user.dart';
import 'info_popup.dart';

class BarkRecorder extends StatefulWidget {
  @override
  BarkRecorderState createState() => BarkRecorderState();
}

class BarkRecorderState extends State<BarkRecorder> {
  late KaraokeCards cards;
  late String filePath;
  bool _isRecording = false;
  late FlutterSoundController soundController;
  double maxDuration = 1.0;
  Timer? _recordingTimer;
  KaraokeCard? card;
  late Barks barks;
  late CurrentActivity currentActivity;
  bool _loading = false;

  // JMF 28/12/2021: added because static access no longer available
  // in ImagePicker 6.2.2
  final ImagePicker _picker = ImagePicker();

  TheUser? user;


  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _recordSound() {
    // barks.deleteTempRawBark();
    print("FilePath: $filePath");
    soundController.record(this.filePath);
    _recordingTimer = Timer(Duration(seconds: 10), () {
      soundController.startPlayer("assets/sounds/bell.aac",
          mediaType: Media.asset);
      stopRecorder();
    });
    this.setState(() {
      this._isRecording = true;
    });
  }

  void startRecorder() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      showError(context, "Microphone permission not granted");
      return;
    }
    try {
      await soundController.startPlayer("assets/sounds/beeoop.aac",
          mediaType: Media.asset, stopCallback: _recordSound);
    } catch (error) {
      print(error.toString());
    }
  }

  void stopRecorder() async {
    _recordingTimer!.cancel();

    setState(() {
      this._isRecording = false;
    });

    await soundController.stopRecording();
    await barks.setTempRawBark(Bark(filePath: filePath));
  }

  // todo -- add alternative to startRecord/StopRecorder to allow selection of fil

  void addCroppedBarksToAllBarks(Barks barks, croppedBarks) async {
    setState(() => _loading = true);
    await barks.uploadRawBarkAndRetrieveCroppedBarks(card!.picture!.fileId);
    setState(() => _loading = false);
  }

  onStartRecorderPressed() {
    print("recorder pressed");
    soundController.isRecording() ? stopRecorder() : startRecorder();
  }

  void _backCallback() {
    currentActivity.setCardCreationStep(CardCreationSteps.song);
  }

  void _skipCallback() {
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
  }

  bool _systemBusy() {
    return _loading || soundController.isPlaying();
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
    var pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile == null) return;
    barks.deleteTempRawBark();
    await FFMpeg.process.execute(
        '-i ${pickedFile.path} -ss 00:00:00 -t 15 -vn -ar 44100 -ac 1 $filePath');
    // FFMpeg.probe.getMediaInformation(filePath).then((info) {
    //   print("Media Information");
    //   print("Channels: ${info.getMediaProperties()['channelLayout']}");
    //   print("Everything: ${info.getAllProperties()}");
    // });

    await barks.setTempRawBark(Bark(filePath: filePath));
  }

  Future<void> _handleCropBarksAndContinue() async {
    setState(() => _loading = true);
    try {
      await barks
          .uploadRawBarkAndRetrieveCroppedBarks(cards.current!.picture!.fileId);
    } catch (e) {
      print(e);
      showError(context, "Check internet connection and try again.");
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = false);
    currentActivity.setCardCreationSubStep(CardCreationSubSteps.two);
  }

  void checkAccountThenUploadVideo(BuildContext ctx) {
    if(user!.email == InfoPopup.guest) {
      InfoPopup.displayInfo(ctx, "Can't load audio from video as guest", InfoPopup.signup);
    }
    else {
      _handleUploadVideoButton();
    }
  }

  void checkAccountThenStartRecorder(BuildContext ctx) {
    if(user!.email == InfoPopup.guest) {
      InfoPopup.displayInfo(ctx, "Can't record audio as guest", InfoPopup.signup);
    }
    else {
      onStartRecorderPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    cards = Provider.of<KaraokeCards>(context);
    soundController = Provider.of<FlutterSoundController>(context);
    barks = Provider.of<Barks>(context, listen: false);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);
    filePath = '$myAppStoragePath/tempRaw.aac';

    user ??= Provider.of<TheUser>(context, listen: false);

    return SizedBox(
      height: 250,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InterfaceTitleNav(
            title: 'CAPTURE BARKS USING',
            titleSize: 16,
            backCallback: _backCallback,
          ),
          _loading
              ? LoadingHalfScreenWidget("Processing Barks...")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Video Upload
                        SizedBox(
                          height: 130,
                          width: 80,
                          child: Column(
                            children: <Widget>[
                              RawMaterialButton(
                                constraints: const BoxConstraints(
                                    minWidth: 70.0, minHeight: 36.0),
                                onPressed: () => _systemBusy()
                                    ? null
                                    : checkAccountThenUploadVideo(context),
                                child: Icon(
                                  Icons.movie,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.all(10.0),
                              ),
                              Padding(padding: EdgeInsets.only(top: 16)),
                              Text("AUDIO FROM VIDEO",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        // Record Audio
                        SizedBox(
                          height: 130,
                          width: 120,
                          child: Column(
                            children: <Widget>[
                              RawMaterialButton(
                                onPressed:() =>
                                    _loading || soundController.isPlaying()
                                        ? null
                                        : checkAccountThenStartRecorder(context),
                                child: _loading
                                    ? SpinKitWave(
                                        color: Colors.white,
                                        size: 15,
                                      )
                                    : Icon(
                                        _isRecording
                                            ? Icons.stop
                                            : Icons.fiber_manual_record,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                shape: _isRecording
                                    ? RoundedRectangleBorder()
                                    : CircleBorder(),
                                elevation: 2.0,
                                fillColor: Theme.of(context).errorColor,
                                padding: const EdgeInsets.all(10.0),
                              ),
                              Padding(padding: EdgeInsets.only(top: 16)),
                              Text(
                                  _isRecording
                                      ? "RECORDING...\nTAP TO STOP"
                                      : "RECORD\nAUDIO",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).errorColor)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        // Record Audio
                        SizedBox(
                          height: 130,
                          width: 75,
                          child: Column(
                            children: <Widget>[
                              // IconButton(
                              //   padding: const EdgeInsets.all(0.0),
                              //   icon: ImageIcon(
                              //     AssetImage("assets/images/BarksAndFX.png"),
                              //     color: Theme.of(context).primaryColor,
                              //   ),
                              //   iconSize: 20,
                              //   onPressed: _skipCallback,
                              // ),
                              RawMaterialButton(
                                onPressed: _skipCallback,
                                child: Image.asset(
                                  "assets/images/BarksAndFX.png",
                                  height: 20,
                                  width: 20,
                                  fit: BoxFit.fitWidth,
                                ),
                                // Icon(
                                //   Icons.contactless,
                                //   size: 20,
                                //   color: Colors.white,
                                // ),
                                shape: CircleBorder(),
                                elevation: 2.0,
                                fillColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.all(10.0),
                              ),
                              Padding(padding: EdgeInsets.only(top: 16)),
                              Text("STOCK BARKS\nAND FX",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ADD BARKS BUTTON
                    // if (barks.tempRawBark == null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 20.0),
                    //     child: Center(
                    //       child: Text(
                    //         "Press 'Skip' to use Stock Barks and FX\nor barks you may have already recorded.",
                    //         style: TextStyle(
                    //           color: Colors.grey,
                    //           fontStyle: FontStyle.italic,
                    //         ),
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ),
                    //   ),
                    if (barks.tempRawBark != null && !_isRecording)
                      GestureDetector(
                        onTap: _handleCropBarksAndContinue,
                        child: Waggle(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              shape: BoxShape.rectangle,
                              color: Theme.of(context).primaryColor,
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
