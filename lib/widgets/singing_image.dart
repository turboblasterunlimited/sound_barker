import 'package:flutter/material.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
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
    print("building singing image");
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
              if (message.message == "[puppet.js postMessage] finished init") {
                imageController.makeInit();
                print("Made ready");
                if (widget.picture != null) {
                  print("pic name: ${widget.picture.name}");
                  imageController.createDog(widget.picture);
                }
              }
              if (message.message ==
                  "[puppet.js postMessage] create_puppet finished") {
                print("create puppet finished");
                imageController.makeReady();
                await imageController.setFace();
                await imageController.setMouthColor();
                imageController.startRandomGesture();
              }
            },
          ),
        ],
      ),
    );
  }

}
