import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImageController with ChangeNotifier{
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void triggerBark() async {
    webViewController.evaluateJavascript("bark(.1, .05)");
  }

  void loadImage(base64Image) async {
    webViewController.evaluateJavascript("update_texture($base64Image)");
  }
}