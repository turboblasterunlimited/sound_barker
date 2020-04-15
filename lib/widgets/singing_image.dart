import 'dart:async';
import 'package:flutter/material.dart';
import 'package:song_barker/providers/image_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/pictures.dart';

class SingingImage extends StatefulWidget {
  @override
  _SingingImageState createState() => _SingingImageState();
}

class _SingingImageState extends State<SingingImage> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  ImageController imageController;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1/1,
      child: WebView(
        onWebViewCreated: (WebViewController c) {
          _controller.complete(c);
          Provider.of<ImageController>(context, listen: false).mountController(c);
          print("WEB VIEW CREATED");

        },
        onPageFinished: (_) {

        },
        
        // initialUrl: 'https://www.thedogbarksthesong.ml/sample_animation',
        initialUrl: 'https://www.thedogbarksthesong.ml/puppet',

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
                if (message.message == "[puppet.js postMessage] finished init") {
                  // here you can either set some var on the instance to ready to 
                  // show that its ready for evaling js, or you could actually make a js
                  // eval call.
                }
                if (message.message == "[puppet.js postMessage] puppet is now ready") {
                  // same thing here, though youd want to set the instance var for puppet ready to 
                  // false before calling create_puppet each time
                }
              })
        ]),
      ),
    );
  }
}
