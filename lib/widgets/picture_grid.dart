import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:song_barker/functions/app_storage_path.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:song_barker/screens/confirm_picture_screen.dart';

import '../providers/pictures.dart';
import '../screens/camera_screen.dart';
import '../widgets/picture_card.dart';
import 'package:path_provider/path_provider.dart';

class PictureGrid extends StatefulWidget {
  @override
  _PictureGridState createState() => _PictureGridState();
}

class _PictureGridState extends State<PictureGrid> {
  @override
  Widget build(BuildContext context) {
    Pictures pictures = Provider.of<Pictures>(context);
    print(myAppStoragePath);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  File file = await FilePicker.getFile(type: FileType.IMAGE);
                  String newFilePath = join(
                    myAppStoragePath,
                    DateTime.now().toString(),
                  );
                  await file.copy(newFilePath);
                  Picture newPicture = Picture(filePath: newFilePath);
                  await newPicture.crop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmPictureScreen(newPicture),
                    ),
                  );
                },
                child: Icon(
                  Icons.filter,
                  color: Colors.black38,
                  size: 40,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
              RawMaterialButton(
                onPressed: () async {
                  List<CameraDescription> cameras = await availableCameras();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(cameras),
                    ),
                  );
                  // print(await appStoragePath());
                },
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.black38,
                  size: 40,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(15.0),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: pictures.all.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: pictures.all[i],
              child: PictureCard(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              // childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
        ),
      ],
    );
  }
}
