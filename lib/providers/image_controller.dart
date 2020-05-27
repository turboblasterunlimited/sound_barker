import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

import '../providers/pictures.dart';

class ImageController with ChangeNotifier {
  WebViewController webViewController;
  Map coordinates;
  bool ready = false;

  void makeReady() {
    ready = true;
    notifyListeners();
  }

  void mountController(controller) {
    this.webViewController = controller;
  }

  void stopAnimation() {
    this.webViewController.evaluateJavascript("stop_all_animations()");
  }

  // Probably Depricated
  void mouthOpen(width) {
    webViewController.evaluateJavascript("mouth_open($width)");
  }

  void mouthTrackSound(String amplitudesFilePath) async {
    final input = new File(amplitudesFilePath).openRead();
    final amplitudes = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();
    webViewController.evaluateJavascript("mouth_track_sound(${amplitudes[0]})");
  }

  Timer randomGesture() {
    int rNum;
    var random = Random.secure();
    Timer randomGestureTimer =
        Timer.periodic(Duration(milliseconds: 1100), (timer) {
      rNum = random.nextInt(40);
      if (rNum <= 3) webViewController.evaluateJavascript("left_brow_raise()");
      if (rNum <= 6 && rNum > 3)
        webViewController.evaluateJavascript("right_brow_raise()");
      if (rNum <= 9 && rNum > 6)
        webViewController.evaluateJavascript("left_brow_furrow()");
      if (rNum <= 12 && rNum > 9)
        webViewController.evaluateJavascript("right_brow_furrow()");
      if (rNum <= 15 && rNum > 12) {
        webViewController.evaluateJavascript("left_blink_quick()");
        webViewController.evaluateJavascript("right_blink_quick()");
      }
      if (rNum <= 18 && rNum > 15) {
        webViewController.evaluateJavascript("left_blink_slow()");
        webViewController.evaluateJavascript("right_blink_slow()");
      }
      if (rNum == 19)
        webViewController.evaluateJavascript("right_blink_quick()");
      if (rNum == 20)
        webViewController.evaluateJavascript("right_blink_slow()");
      if (rNum == 21)
        webViewController.evaluateJavascript("left_blink_quick()");
      if (rNum == 22) webViewController.evaluateJavascript("left_blink_slow()");
    });
    return randomGestureTimer;
  }

  // SHOULD ALSO CHECK FOR THE EXISTENCE OF pictures.mountedPicture and then pass it to create_dog.
  // NEED TO FIX ISSUE OF WIDGET SCREENS REBUILDING AFTER THEY HAVE BEEN LEFT.
  dynamic createDog(Picture picture) {
    if (!ready) {
      print("Not ready!");
      Future.delayed(Duration(seconds: 1), createDog(picture));
    }
    print("Making it!");
    webViewController
        .evaluateJavascript("create_puppet('${_base64Image(picture)}')");
    this.coordinates = json.decode(picture.coordinates);
    setFace();
  }

  String _base64Image(picture) {
    String encodingPrefix = "data:image/png;base64,";
    String base64Image =
        base64.encode(File(picture.filePath).readAsBytesSync());
    return '$encodingPrefix$base64Image';
  }

  void setFace() {
    print("setting face");
    webViewController.evaluateJavascript(
        "set_position('rightEyePosition', ${coordinates['rightEye'][0]}, ${coordinates['rightEye'][1]})");
    webViewController.evaluateJavascript(
        "set_position('leftEyePosition', ${coordinates['leftEye'][0]}, ${coordinates['leftEye'][1]})");
    webViewController.evaluateJavascript(
        "set_position('mouthPosition', ${coordinates['mouth'][0]}, ${coordinates['mouth'][1]})");
    webViewController.evaluateJavascript(
        "set_position('mouthRight', ${coordinates['mouthRight'][0]}, ${coordinates['mouthRight'][1]})");
    webViewController.evaluateJavascript(
        "set_position('mouthLeft', ${coordinates['mouthLeft'][0]}, ${coordinates['mouthLeft'][1]})");
    webViewController.evaluateJavascript(
        "set_position('headTop', ${coordinates['headTop'][0]}, ${coordinates['headTop'][1]})");
    webViewController.evaluateJavascript(
        "set_position('headRight', ${coordinates['headRight'][0]}, ${coordinates['headRight'][1]})");
    webViewController.evaluateJavascript(
        "set_position('headBottom', ${coordinates['headBottom'][0]}, ${coordinates['headBottom'][1]})");
    webViewController.evaluateJavascript(
        "set_position('headLeft', ${coordinates['headLeft'][0]}, ${coordinates['headLeft'][1]})");
    print("done setting face");
  }
}
