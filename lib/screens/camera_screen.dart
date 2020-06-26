// DOESN'T WORK WITH IOS EMULATOR



import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:K9_Karaoke/tools/app_storage_path.dart';

import '../tools/cropper.dart';
import 'confirm_picture_screen.dart';
import '../providers/pictures.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = 'camera-screen';
  final cameras;
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
    print("Building camera screen.");
    var outlineColor = Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).primaryColor, size: 30),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          
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
                      backgroundColor: Colors.white,
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
