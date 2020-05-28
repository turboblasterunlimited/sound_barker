import 'dart:async';
import 'package:flutter/material.dart';
import 'package:song_barker/providers/image_controller.dart';
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
  // static Completer<WebViewController> _controller =
  //     Completer<WebViewController>();
  static WebViewController webviewController;
  Timer randomGesture;

  void dispose() {
    if (randomGesture != null) randomGesture.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context, listen: true);

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
      // initialUrl: "https://www.google.com",

      initialUrl: "https://thedogbarksthesong.ml/puppet_002/puppet.html",
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: Set.from(
        [
          JavascriptChannel(
            name: 'Print',
            onMessageReceived: (JavascriptMessage message) {
              //This is where you receive message from
              //javascript code and handle in Flutter/Dart
              //like here, the message is just being printed
              //in Run/LogCat window of android studio
              print(message.message);
              // do things depending on the message
              if (message.message == "[puppet.js postMessage] finished init") {
                // here you can either set some var on the instance to ready to
                // show that its ready for evaling js, or you could actually make a js
                // eval call.
                if (widget.picture != null)
                  imageController.createDog(widget.picture);
                imageController.makeReady();
              }
              if (message.message ==
                  "[puppet.js postMessage] create_puppet finished") {
                Future.delayed(Duration(seconds: 3), () {
                  imageController.randomGesture();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
