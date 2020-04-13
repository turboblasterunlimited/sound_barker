import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class ImageController with ChangeNotifier {
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void setMouth(width) async {
    webViewController.evaluateJavascript("set_mouth($width)");
  }

  // THE TIMER SHOULD ALSO CHECK FOR THE EXISTENCE OF pictures.mountedPicture and then pass it to create_dog.
  void createDogWhenReady([picture]) {
    String result;
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      try {
        result = await webViewController.evaluateJavascript('ready');
        if (result == "1") {
          print("ITS TRUE");
          createDog(picture);
          timer.cancel();
        } else {
          print("It's not ready... YET");
        }
      } on PlatformException catch (e) {
        print("Not ready.");
      } on NoSuchMethodError {
        print("Webview Widget not yet loaded.");
      }
    });
  }

    // NEED TO FIX ISSUE OF WIDGET SCREENS REBUILDING AFTER THEY HAVE BEEN LEFT.
  createDog(picture) {
    if (picture != null) {
      String enfluttercodingPrefix = "data:image/png;base64,";
      String base64Image =
          base64.encode(File(picture.filePath).readAsBytesSync());
      
      // Temp fix
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        webViewController
            .evaluateJavascript("create_dog('$encodingPrefix$base64Image')");
      });
      webViewController.evaluateJavascript(
          "set_mouth_coordinates(${picture.mouthCoordinates})");
    } else {
      webViewController.evaluateJavascript("create_dog()");
    }
  }

  
}
