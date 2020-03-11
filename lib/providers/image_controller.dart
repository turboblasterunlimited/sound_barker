import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImageController with ChangeNotifier {
  WebViewController webViewController;

  void mountController(controller) {
    this.webViewController = controller;
  }

  void triggerBark({duration= .2, distance= .05}) async {
    print("Bark Triggered... Duration:$duration, Distance: $distance");
    
    webViewController.evaluateJavascript("bark($duration, $distance)");
  }

  void loadImage(base64Image) async {
    webViewController.evaluateJavascript("update_texture($base64Image)");
  }
}
