import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:song_barker/tools/app_storage_path.dart';

import '../tools/cropper.dart';
import 'confirm_picture_screen.dart';
import '../providers/pictures.dart';

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
    var outlineColor = Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Song Barker',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                shadows: [
                  Shadow(
                      // bottomLeft
                      offset: Offset(-1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // bottomRight
                      offset: Offset(1.5, -1.5),
                      color: outlineColor),
                  Shadow(
                      // topRight
                      offset: Offset(1.5, 1.5),
                      color: outlineColor),
                  Shadow(
                      // topLeft
                      offset: Offset(-1.5, 1.5),
                      color: outlineColor),
                ],
                color: Colors.white),
          ),
        ),
      ),
      body: !_controller.value.isInitialized
          ? Container()
          : Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                ),
                Expanded(
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.camera_alt),
                      onPressed: () async {
                        Picture newPicture = Picture();
                        try {
                          final filePath = join(
                            myAppStoragePath,
                            newPicture.fileId + ".jpg",
                          );
                          print("SAVEing TempIMAGE TO $filePath");
                          await _controller.takePicture(filePath);
                          newPicture.filePath = filePath;
                          // await newPicture.crop();
                          await cropImage(newPicture, Theme.of(context).accentColor, Colors.white);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConfirmPictureScreen(newPicture),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
