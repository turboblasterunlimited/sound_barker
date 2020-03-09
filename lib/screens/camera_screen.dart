import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'dart:io';
import 'package:image/image.dart' as IMG;
import 'package:song_barker/functions/app_storage_path.dart';
import 'dart:math';

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

  Future<String> _cropPhoto(String filePath) async {
    var bytes = await File(filePath).readAsBytes();
    IMG.Image src = IMG.decodeImage(bytes);

    var cropSize = min(src.width, src.height);
    int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage =
        IMG.copyCrop(src, offsetX, offsetY, cropSize, cropSize);

    var jpg = IMG.encodeJpg(destImage);

    File(filePath).deleteSync();

    await File(filePath).writeAsBytes(jpg);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var outlineColor = Colors.black;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
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
      body: !_controller.value.isInitialized
          ? Container()
          : Column(
              children: <Widget>[
                Container(
                  width: _width,
                  height: _width * .8,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          width: _width,
                          height: (_width * .8) / _controller.value.aspectRatio,
                          child: CameraPreview(
                              _controller),
                        ),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: AspectRatio(
                //     aspectRatio: _controller.value.aspectRatio,
                //     child: CameraPreview(_controller),
                //   ),
                // ),
                Center(
                  child: FloatingActionButton(
                    child: Icon(Icons.camera_alt),
                    onPressed: () async {
                      try {
                        final tempPath = join(
                          await appStoragePath(),
                          DateTime.now().toString(),
                        );
                        print("SAVEing TempIMAGE TO $tempPath");
                        await _controller.takePicture(tempPath);
                        String croppedPhotoPath = await _cropPhoto(tempPath);
                        print("SAVEing CroppedIMAGE TO $croppedPhotoPath");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConfirmPictureScreen(croppedPhotoPath),
                          ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
