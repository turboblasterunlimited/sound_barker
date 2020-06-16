import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

import '../tools/cropper.dart';
import 'package:K9_Karaoke/screens/confirm_picture_screen.dart';
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
          Expanded(
            child: Column(
              children: <Widget>[
                AppBar(
                  centerTitle: true,
                  backgroundColor: Theme.of(context).accentColor,
                  title: Text('Pictures'),
                  automaticallyImplyLeading: false,
                  actions: [Container()],
                ),
                ButtonBar(
                  buttonPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      onPressed: () async {
                        File file =
                            await FilePicker.getFile(type: FileType.IMAGE);
                        Picture newPicture = Picture();
                        final newFilePath = join(
                          myAppStoragePath,
                          newPicture.fileId + ".jpg",
                        );
                        await file.copy(newFilePath);
                        newPicture.filePath = newFilePath;
                        print("Original filepath: ${newPicture.filePath}");
                        await cropImage(newPicture,
                            Theme.of(context).accentColor, Colors.white);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConfirmPictureScreen(newPicture),
                          ),
                        );
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.filter,
                            color: Colors.black38,
                            size: 30,
                          ),
                          Text("Picker"),
                        ],
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
                        List<CameraDescription> cameras =
                            await availableCameras();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(cameras),
                          ),
                        );
                      },
                      child: Column(children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          color: Colors.black38,
                          size: 30,
                        ),
                        Text("Camera"),
                      ]),
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
                    controller: null,
                    padding: const EdgeInsets.all(10),
                    itemCount: pictures.all.length,
                    itemBuilder: (_, i) => ChangeNotifierProvider.value(
                      value: pictures.all[i],
                      key: UniqueKey(),
                      child: PictureCard(i, pictures.all[i], pictures),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
