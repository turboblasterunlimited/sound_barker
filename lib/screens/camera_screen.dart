import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'confirm_picture_screen.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = 'camera-screen';
  dynamic cameras;
  CameraScreen(this.cameras);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameras.first, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Song Barker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: !_controller.value.isInitialized
          ? Container()
          : AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            final imagePath = join(
              (await getTemporaryDirectory()).path,
              DateTime.now().toString(),
            );
            print("ATTEMPTING TO SAVE IMAGE TO $imagePath");
            await _controller.takePicture(imagePath);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPictureScreen(imagePath),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
