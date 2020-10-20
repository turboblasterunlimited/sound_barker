import 'package:K9_Karaoke/globals.dart';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/providers/image_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class SingingImage extends StatefulWidget {
  @override
  _SingingImageState createState() => _SingingImageState();
}

class _SingingImageState extends State<SingingImage>
    with AutomaticKeepAliveClientMixin {
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
    super.build(context);
    print("building singing image");
    imageController = Provider.of<ImageController>(context);

    return AspectRatio(
      aspectRatio: 1,
      child: IgnorePointer(
        ignoring: true,
        child: WebView(
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
          initialUrl: "https://$serverURL/puppet/app_puppet.html",
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from(
            [
              JavascriptChannel(
                name: 'Print',
                onMessageReceived: (JavascriptMessage message) async {
                  // print(message.message);
                  if (message.message ==
                      "[puppet.js postMessage] finished init") {
                    imageController.makeInit();
                    print("Made ready");
                    if (imageController.picture != null) {
                      print(
                          "Creat dog from within singing image. picturename: ${imageController.picture.name}");
                      await imageController.createDog(imageController.picture);
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
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
