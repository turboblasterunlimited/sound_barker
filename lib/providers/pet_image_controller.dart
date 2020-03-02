import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PetImageController with ChangeNotifier{
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void triggerBark() async {
    webViewController.evaluateJavascript("bark(.1, .05)");
  }
}