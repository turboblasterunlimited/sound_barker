import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PetImage extends StatefulWidget {
  PetImage();

  @override
  _PetImageState createState() => _PetImageState();
}

class _PetImageState extends State<PetImage> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  void triggerBark() async {
    await Future.delayed(Duration(seconds: 3));
    flutterWebviewPlugin.evalJavascript("bark()");
    triggerBark();
  }

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.evalJavascript("bark()");
    triggerBark();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    flutterWebviewPlugin.onUrlChanged.listen((String url) {});
    // flutterWebviewPlugin.launch(
    //   'http://165.227.178.14/sample_animation',
      // rect: new Rect.fromLTWH(
      //   0.0,
      //   0.0,
      //   MediaQuery.of(context).size.width,
      //   300.0,
      // ),
    // );
    return WebviewScaffold(
      url: 'http://165.227.178.14/sample_animation',
      withJavascript: true,
      scrollBar: true,
      displayZoomControls: true,
      withZoom: true,
    );
  }
}
