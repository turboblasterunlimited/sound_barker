import 'dart:async';
import 'package:flutter/material.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';
import '../screens/select_song_and_picture_screen.dart';

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
  static ImageController imageController;
  Timer randomGesture;

  void dispose() {
    randomGesture.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Stack(
        children: <Widget>[
          WebView(
            onWebViewCreated: (WebViewController c) {
              webviewController = c;
              // _controller.complete(webviewController);
              imageController =
                  Provider.of<ImageController>(context, listen: false);

              print("WEB VIEW CREATED");
            },
            onPageFinished: (_) {
              print("WEB VIEW \"FINISHED\"");
              imageController.mountController(webviewController);
            },

            // initialUrl: 'https://www.thedogbarksthesong.ml/sample_animation',
            // initialUrl: 'https://www.thedogbarksthesong.ml/puppet',
            initialUrl: "https://thedogbarksthesong.ml/puppet_001/puppet.html",

            // initialUrl: 'http://webglreport.com/',
            // initialUrl: 'https://html5test.com/',
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: Set.from([
              JavascriptChannel(
                  name: 'Print',
                  onMessageReceived: (JavascriptMessage message) {
                    //This is where you receive message from
                    //javascript code and handle in Flutter/Dart
                    //like here, the message is just being printed
                    //in Run/LogCat window of android studio
                    print(message.message);
                    // do things depending on the message
                    if (message.message ==
                        "[puppet.js postMessage] finished init") {
                      // here you can either set some var on the instance to ready to
                      // show that its ready for evaling js, or you could actually make a js
                      // eval call.
                      imageController.createDog(widget.picture);
                    }
                    if (message.message ==
                        "[puppet.js postMessage] puppet is now ready") {
                      // same thing here, though youd want to set the instance var for puppet ready to
                      // false before calling create_puppet each time
                      imageController.animate();
                    }
                    if (message.message ==
                        "[puppet.js postMessage] create_puppet finished") {
                      // call set face
                      imageController.setFace();
                      if (randomGesture != null) randomGesture.cancel();
                      randomGesture = imageController.randomGesture();
                    }
                  })
            ]),
          ),
          Stack(children: <Widget>[
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ])
        ],
      ),
    );
  }
}
