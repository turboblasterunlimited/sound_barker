import 'dart:io';

import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/confirm_picture_screen.dart';
import 'package:K9_Karaoke/screens/menu_screen.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

class PictureMenuScreen extends StatefulWidget {
  static const routeName = 'picture-menu-screen';

  @override
  _PictureMenuScreenState createState() => _PictureMenuScreenState();
}

class _PictureMenuScreenState extends State<PictureMenuScreen> {
  Pictures pictures;

  Future<void> _cropAndNavigate(newPicture) async {
    await cropImage(newPicture, Theme.of(context).backgroundColor,
        Theme.of(context).primaryColor);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmPictureScreen(newPicture),
      ),
    );
  }

  Future getImage(source) async {
    final newPicture = Picture();
    newPicture.filePath = "$myAppStoragePath/${newPicture.fileId}.jpg";

    final pickedFile = await ImagePicker().getImage(source: source);
    final bytes = await pickedFile.readAsBytes();

    File(newPicture.filePath).writeAsBytesSync(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    await _cropAndNavigate(newPicture);
  }

  Widget build(BuildContext context) {
    pictures = Provider.of<Pictures>(context, listen: false);
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
          leading: Icon(LineAwesomeIcons.paw),
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
                  Navigator.of(context).pushNamed(MenuScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                child: Text("Take A Picture", style: TextStyle(fontSize: 20)),
                color: Theme.of(context).primaryColor,
                onPressed: () => getImage(ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                child: Text("Phone Storage", style: TextStyle(fontSize: 20)),
                color: Theme.of(context).primaryColor,
                onPressed: () => getImage(ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                child: Text("Photo Library", style: TextStyle(fontSize: 20)),
                color: Theme.of(context).primaryColor,
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
