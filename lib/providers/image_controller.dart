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
    webViewController.evaluateJavascript("set_mouth($width)");
  }

  void loadImage(picture) async {
    String encodingPrefix = "data:image/png;base64,";
    String base64Image = base64.encode(File(picture.filePath).readAsBytesSync());
    webViewController
        .evaluateJavascript("update_texture('$encodingPrefix$base64Image')");
    print("Setting mouth coordinates... Which are: ${picture.mouthCoordinates}");
    webViewController.evaluateJavascript("set_mouth_coordinates(${picture.mouthCoordinates})");
    print("Done!");

  }
}
