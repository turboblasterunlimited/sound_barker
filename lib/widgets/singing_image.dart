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
        },
        onPageFinished: (_) {

          // final picture = Provider.of<Pictures>(context, listen: false).mountedPicture;
          // imageController.loadImage(picture);
          // imageController.createDog();
        },
        
        initialUrl: 'https://www.thedogbarksthesong.ml/sample_animation',
        // initialUrl: 'http://webglreport.com/',
        // initialUrl: 'https://html5test.com/',
        javascriptMode: JavascriptMode.unrestricted,
        // javascriptChannels: <JavascriptChannel> [

        // ].toSet(),
      ),
    );
  }
}
