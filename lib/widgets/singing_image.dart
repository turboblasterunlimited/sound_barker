import 'dart:async';
import 'package:flutter/material.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class SingingImage extends StatefulWidget {

  @override
  _SingingImageState createState() => _SingingImageState();
}

class _SingingImageState extends State<SingingImage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  // WebViewController controller;

  // void triggerBark(controller) async {
  //   await Future.delayed(Duration(seconds: 3));
  //   controller.evaluateJavascript("bark()");
  // }

  @override
  Widget build(BuildContext context) {
    return Flexible(
          flex: 1,
          child: WebView(
        onWebViewCreated: (WebViewController c) {
          _controller.complete(c);
          Provider.of<ImageController>(context, listen: false).mountController(c);

        },
        initialUrl: 'http://165.227.178.14/sample_animation',
        javascriptMode: JavascriptMode.unrestricted,
        // javascriptChannels: <JavascriptChannel> [

        // ].toSet(),
      ),
    );
  }
}
