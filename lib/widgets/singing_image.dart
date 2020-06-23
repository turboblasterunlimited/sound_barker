import 'dart:async';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';

class SingingImage extends StatefulWidget {
  Picture picture;
  SingingImage([this.picture]);

  @override
  _SingingImageState createState() => _SingingImageState();
}

class _SingingImageState extends State<SingingImage> {
  WebViewController webviewController;
  ImageController imageController;

  @override
  void dispose() {
    print("Disposing Random gestures");
    imageController.randomGestureTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    imageController = Provider.of<ImageController>(context);

    return WebView(
      gestureRecognizers: null,
      onWebViewCreated: (WebViewController c) {
        webviewController = c;
        // _controller.complete(webviewController);
        print("WEB VIEW CREATED");
      },
      onPageFinished: (_) {
        print("WEB VIEW \"FINISHED\"");
        imageController.mountController(webviewController);
      },
      initialUrl: "https://thedogbarksthesong.ml/puppet_002/puppet.html",
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: Set.from(
        [
          JavascriptChannel(
            name: 'Print',
            onMessageReceived: (JavascriptMessage message) async {
              //This is where you receive message from
              //javascript code and handle in Flutter/Dart
              //like here, the message is just being printed
              //in Run/LogCat window of android studio

              // print(message.message);

              // do things depending on the message
              if (message.message == "[puppet.js postMessage] finished init") {
                // here you can either set some var on the instance to ready to
                // show that its ready for evaling js, or you could actually make a js
                // eval call.
                imageController.makeInit();
                print("Made ready");
                if (widget.picture != null) {
                  print("pic name: ${widget.picture.name}");
                  imageController.createDog(widget.picture);
                }
              }
              if (message.message ==
                  "[puppet.js postMessage] create_puppet finished") {
                imageController.makeReady();
                print("pic: ${widget.picture}");

                await imageController.setFace();
                imageController.startRandomGesture();
                imageController.webViewController.evaluateJavascript(
                    'mouth_color(0.5686274509, 0.39607843137, 0.43137254902)');
              }
            },
          ),
        ],
      ),
    );
  }
}
