import 'dart:async';
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

  void blink(width) async {
    webViewController.evaluateJavascript("blink($width)");
  }

  void blinkEverySecondTest() {
    Future.delayed(Duration(seconds: 1), () {
      Timer.periodic(Duration(seconds: 1), (_) {
        webViewController.evaluateJavascript("blink(1)");
      });
    });

    Timer.periodic(Duration(seconds: 1), (_) {
      webViewController.evaluateJavascript("blink(0)");
    });
  }

  // SHOULD ALSO CHECK FOR THE EXISTENCE OF pictures.mountedPicture and then pass it to create_dog.
  // NEED TO FIX ISSUE OF WIDGET SCREENS REBUILDING AFTER THEY HAVE BEEN LEFT.
  createDog([Picture picture]) {
    if (picture == null) return webViewController.evaluateJavascript("create_puppet()");

    String encodingPrefix = "data:image/png;base64,";
    String base64Image =
        base64.encode(File(picture.filePath).readAsBytesSync());

    Map coordinates = json.decode(picture.coordinates);
    List rightEye = coordinates["rightEye"];
    List leftEye = coordinates["rightEye"];

    webViewController
        .evaluateJavascript("create_puppet('$encodingPrefix$base64Image')");

    // Future.delayed(Duration(milliseconds: 2000)).then((_) {
    webViewController.evaluateJavascript("set_eye('right', $rightEye)");
    webViewController.evaluateJavascript("set_eye('left', $leftEye)");
    // });
    // blinkEverySecondTest();
  }
}
