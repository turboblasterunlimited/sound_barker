import 'dart:io';

import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/cropper.dart';
import 'package:K9_Karaoke/widgets/picture_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class PhotoLibraryScreen extends StatefulWidget {
  static const routeName = 'photo-library-screen';

  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  Pictures pictures;

  Future<void> _cropAndNavigate(newPicture) async {
    await cropImage(newPicture, Theme.of(context).primaryColor,
        Colors.white);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetPictureCoordinatesScreen(newPicture),
      ),
    );
  }

  Future getImage(source) async {
    final newPicture = Picture();
    newPicture.filePath = "$myAppStoragePath/${newPicture.fileId}.jpg";

    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();

    File(newPicture.filePath).writeAsBytesSync(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    await _cropAndNavigate(newPicture);
  }

  Widget build(BuildContext context) {
    pictures = Provider.of<Pictures>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Don't show the leading button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logos/K9_logotype.png", width: 100),
              // Your widgets here
            ],
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RawMaterialButton(
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 30,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                onPressed: () {
                  Navigator.of(context).popAndPushNamed(MenuScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        // appbar offset
        padding: EdgeInsets.only(top: 80),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/create_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .popAndPushNamed(MenuScreen.routeName);
                    },
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left),
                      Text('Back'),
                    ]),
                  ),
                  Center(
                    child: Text('PHOTO LIBRARY',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                  ),
                ],
              ),
            ),
            Center(
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Text("Camera", style: TextStyle(fontSize: 20)),
                      // color: Theme.of(context).primaryColor,
                      onPressed: () => getImage(ImageSource.camera),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Text("Upload", style: TextStyle(fontSize: 20)),
                      // color: Theme.of(context).primaryColor,
                      onPressed: () => getImage(ImageSource.gallery),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: pictures.combinedPictures.length,
                  itemBuilder: (_, i) => ChangeNotifierProvider.value(
                    value: pictures.combinedPictures[i],
                    key: UniqueKey(),
                    child:
                        PictureCard(i, pictures.combinedPictures[i], pictures),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // childAspectRatio: 3 / 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
