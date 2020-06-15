import 'dart:async';
import 'dart:math';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

import '../providers/pictures.dart';

class ImageController with ChangeNotifier {
  WebViewController webViewController;
  Map coordinates;
  bool isInit = false;
  bool isReady = false;
  Timer randomGestureTimer;

  void makeReady() {
    isReady = true;
    notifyListeners();
  }

  void makeInit() {
    isInit = true;
    notifyListeners();
  }

  void resetReadyInit() {
    isReady = false;
    isInit = false;
  }

  void mountController(controller) {
    this.webViewController = controller;
    notifyListeners();
  }

  void stopAnimation() {
    // Pass false to keep headsway alive
    this.webViewController.evaluateJavascript("stop_all_animations(false)");
  }

  // Probably Depricated
  void mouthOpen(width) {
    webViewController.evaluateJavascript("mouth_open($width)");
  }

  void mouthTrackSound(
      {String filePath, List amplitudes}) async {
    stopAnimation();
    if (filePath != null) {
      List amplitudes = await AmplitudeExtractor.fileToList(filePath);
      webViewController
          .evaluateJavascript("mouth_track_sound($amplitudes)");
    } else if (amplitudes != null) {
      webViewController.evaluateJavascript("mouth_track_sound($amplitudes)");
    }
  }

  Timer startRandomGesture() {
    // webViewController.evaluateJavascript("update_head_sway(2, 1)");
    randomGestureTimer?.cancel();
    int rNum;
    var random = Random.secure();
    // amplitude, speed, duration
    String browGestureSettings = "";
    final timer = Timer.periodic(Duration(milliseconds: 4000), (timer) {
      browGestureSettings =
          '0.${3 + random.nextInt(3)}, ${1 + random.nextInt(3)}0, ${1 + random.nextInt(3)}500';
      rNum = random.nextInt(30);
      if (rNum <= 4)
        webViewController
            .evaluateJavascript("left_brow_raise($browGestureSettings)");
      if (rNum <= 6 && rNum > 2)
        webViewController
            .evaluateJavascript("right_brow_raise($browGestureSettings)");
      if (rNum <= 9 && rNum > 6)
        webViewController
            .evaluateJavascript("left_brow_furrow($browGestureSettings)");
      if (rNum <= 12 && rNum > 9)
        webViewController
            .evaluateJavascript("right_brow_furrow($browGestureSettings)");
      if (rNum == 15 || rNum == 13) {
        webViewController.evaluateJavascript("left_blink_quick()");
        webViewController.evaluateJavascript("right_blink_quick()");
      }
      if (rNum % 2 == 0) {
        webViewController.evaluateJavascript("left_blink_slow()");
        webViewController.evaluateJavascript("right_blink_slow()");
      }
      if (rNum == 19)
        webViewController.evaluateJavascript("right_blink_quick()");
      if (rNum == 21)
        webViewController.evaluateJavascript("right_blink_slow()");
    });
    return this.randomGestureTimer = timer;
  }

  Future createDog(Picture picture) async {
    // This is to handle createDog(pic) getting on startup after pics download, if it completes before webview is init.
    if (!isInit) {
      print("Not ready");
      await Future.delayed(Duration(seconds: 1), () {
        return createDog(picture);
      });
    }
    this.coordinates = await json.decode(picture.coordinates);
    await webViewController
        .evaluateJavascript("create_puppet('${_base64Image(picture)}')");
  }

  String _base64Image(picture) {
    String encodingPrefix = "data:image/png;base64,";
    String base64Image =
        base64.encode(File(picture.filePath).readAsBytesSync());
    return '$encodingPrefix$base64Image';
  }

  Future<void> setFace() async {
    print("Coordinates: $coordinates");
    print("setting face");
    await webViewController.evaluateJavascript(
        "set_position('rightEyePosition', ${coordinates['rightEye'][0]}, ${coordinates['rightEye'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('leftEyePosition', ${coordinates['leftEye'][0]}, ${coordinates['leftEye'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('mouthPosition', ${coordinates['mouth'][0]}, ${coordinates['mouth'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('mouthRight', ${coordinates['mouthRight'][0]}, ${coordinates['mouthRight'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('mouthLeft', ${coordinates['mouthLeft'][0]}, ${coordinates['mouthLeft'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('headTop', ${coordinates['headTop'][0]}, ${coordinates['headTop'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('headRight', ${coordinates['headRight'][0]}, ${coordinates['headRight'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('headBottom', ${coordinates['headBottom'][0]}, ${coordinates['headBottom'][1]})");
    await webViewController.evaluateJavascript(
        "set_position('headLeft', ${coordinates['headLeft'][0]}, ${coordinates['headLeft'][1]})");
    print("done setting face");
  }
}
