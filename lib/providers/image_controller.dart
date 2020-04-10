import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';

class ImageController with ChangeNotifier {
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void setMouth(width) async {
    // print("SET MOUTH called!");
    webViewController.evaluateJavascript("set_mouth($width)");
  }

  // void loadImage(picture) async {
  //   print("load image called");
  //   if (picture != null) {
  //     String encodingPrefix = "data:image/png;base64,";
  //     String base64Image =
  //         base64.encode(File(picture.filePath).readAsBytesSync());
  //     webViewController
  //         .evaluateJavascript("update_texture('$encodingPrefix$base64Image')");
  //     print(
  //         "Setting mouth coordinates... Which are: ${picture.mouthCoordinates}");
  //     webViewController.evaluateJavascript(
  //         "set_mouth_coordinates(${picture.mouthCoordinates})");
  //     print("Done!");
  //   }
  // }

  void createDog([picture]) async {
    print("CREATE dog called!");

    if (picture != null) {
      String encodingPrefix = "data:image/png;base64,";
      String base64Image =
          base64.encode(File(picture.filePath).readAsBytesSync());
      
      // THIS NEEDS TO BE FIXED.
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        webViewController
            .evaluateJavascript("create_dog('$encodingPrefix$base64Image')");
      });
      webViewController.evaluateJavascript(
          "set_mouth_coordinates(${picture.mouthCoordinates})");
    } else {
      webViewController.evaluateJavascript("create_dog()");
    }
    print("done!");
  }
}
