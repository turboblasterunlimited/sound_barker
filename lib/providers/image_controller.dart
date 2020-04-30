import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

import '../providers/pictures.dart';

class ImageController with ChangeNotifier {
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void mouthOpen(width) {
    webViewController.evaluateJavascript("mouth_open($width)");
  }

  void mouthTrackSound(List<double> amplitudes) {
    webViewController.evaluateJavascript("mouth_track_sound($amplitudes)");
  }

  Timer randomGesture() {
    int rNum;
    var random = Random.secure();
    var timer = Timer.periodic(Duration(milliseconds: 900), (timer) {
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
      if (rNum == 22)
        webViewController.evaluateJavascript("left_blink_slow()");
    });
    return timer;
  }

  // void blinkEverySecondTest() {
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     Timer.periodic(Duration(seconds: 1), (_) {
  //       webViewController.evaluateJavascript("blink(1)");
  //     });
  //   });

  //   Timer.periodic(Duration(seconds: 1), (_) {
  //     webViewController.evaluateJavascript("blink(0)");
  //   });
  // }

  // SHOULD ALSO CHECK FOR THE EXISTENCE OF pictures.mountedPicture and then pass it to create_dog.
  // NEED TO FIX ISSUE OF WIDGET SCREENS REBUILDING AFTER THEY HAVE BEEN LEFT.
  createDog([Picture picture]) {
    if (picture == null)
      return webViewController.evaluateJavascript("create_puppet()");

    webViewController
        .evaluateJavascript("create_puppet('${_base64Image(picture)}')");
    setFace(json.decode(picture.coordinates));
    // blinkEverySecondTest();
  }

  void animate() {
    webViewController.evaluateJavascript("animate()");
  }

  _base64Image(picture) {
    String encodingPrefix = "data:image/png;base64,";
    String base64Image =
        base64.encode(File(picture.filePath).readAsBytesSync());
    return '$encodingPrefix$base64Image';
  }

  setFace(coordinates) {
    Future.delayed(Duration(milliseconds: 2000)).then((_) {
      webViewController.evaluateJavascript(
          "set_position('rightEyePosition', ${coordinates['rightEye'][0]}, ${coordinates['rightEye'][1]})");
      webViewController.evaluateJavascript(
          "set_position('leftEyePosition', ${coordinates['leftEye'][0]}, ${coordinates['leftEye'][1]})");
      webViewController.evaluateJavascript(
          "set_position('mouthPosition', ${coordinates['mouth'][0]}, ${coordinates['mouth'][1]})");
      webViewController.evaluateJavascript(
          "set_position('headTop', ${coordinates['headTop'][0]}, ${coordinates['headTop'][1]})");
      webViewController.evaluateJavascript(
          "set_position('headRight', ${coordinates['headRight'][0]}, ${coordinates['headRight'][1]})");
      webViewController.evaluateJavascript(
          "set_position('headBottom', ${coordinates['headBottom'][0]}, ${coordinates['headBottom'][1]})");
      webViewController.evaluateJavascript(
          "set_position('headLeft', ${coordinates['headLeft'][0]}, ${coordinates['headLeft'][1]})");
    });
  }
}
