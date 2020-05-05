import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:song_barker/functions/app_storage_path.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

import 'package:song_barker/providers/tab_list_scroll_controller.dart';
import 'package:song_barker/screens/confirm_picture_screen.dart';
import '../providers/pictures.dart';
import '../screens/camera_screen.dart';
import '../widgets/picture_card.dart';

class PictureGrid extends StatelessWidget {
//   @override
//   _PictureGridState createState() => _PictureGridState();
// }

// class _PictureGridState extends State<PictureGrid> {

  @override
  Widget build(BuildContext context) {
    print("picture grid building");
    Pictures pictures = Provider.of<Pictures>(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          ButtonBar(
            // buttonPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () async {
                  File file = await FilePicker.getFile(type: FileType.IMAGE);
                  Picture newPicture = Picture();
                  final newFilePath = join(
                    myAppStoragePath,
                    newPicture.fileId + ".jpg",
                  );
                  await file.copy(newFilePath);
                  newPicture.filePath = newFilePath;
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
                  size: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  // side: BorderSide(color: Colors.red),
                ),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(5.0),
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
                },
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.black38,
                  size: 30,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  // side: BorderSide(color: Colors.red),
                ),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(5.0),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              controller:
                  Provider.of<TabListScrollController>(context, listen: false)
                      .scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: pictures.all.length,
              itemBuilder: (_, i) => ChangeNotifierProvider.value(
                value: pictures.all[i],
                key: UniqueKey(),
                child: PictureCard(i, pictures.all[i], pictures),
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
      ),
    );
  }
}
