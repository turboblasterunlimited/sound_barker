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
  Picture picture;
  bool isInit = false;
  bool isReady = false;
  Timer randomGestureTimer;
  Timer mouthOpenAndClose;
  bool isPlaying = false;

  void setPicture(Picture pic) {
    picture = pic;
  }

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
    print("Controller set...");
    notifyListeners();
  }

  void cancelMouthOpenAndClose() {
    if (mouthOpenAndClose != null) {
      mouthOpenAndClose.cancel();
      mouthOpenAndClose = null;
      stopAnimation();
    }
  }

  void stopAnimation() {
    isPlaying = false;
    // Pass false to keep headsway alive
    this.webViewController.evaluateJavascript("stop_all_animations(false)");
    // notifyListeners();
  }

  // Probably Depricated
  void mouthOpen(width) {
    webViewController.evaluateJavascript("mouth_open($width)");
  }

  Future<void> mouthTrackSound({String filePath, List amplitudes}) async {
    if (isPlaying) stopAnimation();
    if (filePath != null) {
      amplitudes = await AmplitudeExtractor.fileToList(filePath);
      webViewController.evaluateJavascript("mouth_track_sound($amplitudes)");
    } else if (amplitudes != null) {
      webViewController.evaluateJavascript("mouth_track_sound($amplitudes)");
    }
    isPlaying = true;
    notifyListeners();
  }

  void startMouthOpenAndClose() {
    if (mouthOpenAndClose != null) return;
    bool mouthOpen = true;
    mouthOpenAndClose = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mouthOpen) {
        webViewController.evaluateJavascript("mouth_to_pos(0, .8, 60)");
      } else {
        webViewController.evaluateJavascript("mouth_to_pos(.8, 0, 60)");
      }
      mouthOpen = !mouthOpen;
    });
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

      // Brow furrows
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
      // blinks and winks
      if (rNum % 2 == 0) {
        webViewController.evaluateJavascript("left_blink_slow()");
        webViewController.evaluateJavascript("right_blink_slow()");
      }
      if (rNum == 13)
        webViewController.evaluateJavascript("left_blink_quick()");
      if (rNum == 15)
        webViewController.evaluateJavascript("right_blink_quick()");
      if (rNum == 17) webViewController.evaluateJavascript("left_blink_slow()");
      if (rNum == 21)
        webViewController.evaluateJavascript("right_blink_slow()");
      if (rNum > 21 && rNum % 2 != 0) {
        webViewController.evaluateJavascript("left_blink_quick()");
        webViewController.evaluateJavascript("right_blink_quick()");
      }
    });
    return this.randomGestureTimer = timer;
  }

  Future createDog(Picture picture) async {
    // This is to handle createDog(pic) getting on startup after pics download, if it completes before webview is init.
    if (!isInit) {
      print("Not ready");
      return await Future.delayed(Duration(seconds: 1), () async {
        await createDog(picture);
      });
    }
    print("picture from within createDog: ${picture.name}");
    setPicture(picture);
    String base64ImageString = await _base64Image(picture);
    try {
      print("Trying to create dog.");
      await webViewController
          .evaluateJavascript("create_puppet('$base64ImageString')");
      print("Create dog succeeded.");
    } catch (e) {
      print("Create dog failed :,(");
    }
    // webViewController
    //     .evaluateJavascript("test('dog1.jpg')");
  }

  Future<String> _base64Image(picture) async {
    String encodingPrefix = "data:image/png;base64,";
    String base64Image;
    base64Image = base64.encode(File(picture.filePath).readAsBytesSync());
    return '$encodingPrefix$base64Image';
  }

  Future<void> setFace() async {
    var coordinates = picture.coordinates;
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

  Future setMouthColor([rgb]) async {
    rgb ??= picture.mouthColor;
    print("Mouth color: $rgb");
    await webViewController
        .evaluateJavascript("mouth_color(${rgb[0]}, ${rgb[1]}, ${rgb[2]});");
    print("done setting mouth color");
  }
}
