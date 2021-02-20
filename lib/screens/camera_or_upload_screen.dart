import 'dart:io';

import 'package:K9_Karaoke/icons/custom_icons.dart';
import 'package:K9_Karaoke/providers/pictures.dart';
import 'package:K9_Karaoke/screens/set_picture_coordinates_screen.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:K9_Karaoke/tools/cropper.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/custom_dialog.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraOrUploadScreen extends StatelessWidget {
  static const routeName = 'camera_or_upload_screen';
  static BuildContext con;

  Future<void> _cropAndNavigate(newPicture, context) async {
    bool cropped = await cropImage(
        newPicture, Theme.of(context).primaryColor, Colors.white);
    if (!cropped) {
      print("not cropped");
      return;
    }
    Navigator.push(
      con,
      MaterialPageRoute(
        builder: (ctx) => SetPictureCoordinatesScreen(newPicture),
      ),
    );
  }

  Future<bool> _getPermission(source, context) async {
    PermissionStatus status;
    if (source == ImageSource.gallery) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        showError(context, "Access to photos denied.");
        return false;
      }
    } else if (source == ImageSource.camera) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        showError(context, "Access to camera denied.");
        return false;
      }
    }
    return true;
  }

  Future getImage(source, context) async {
    if (!await _getPermission(source, context)) return;

    final newPicture = Picture();
    newPicture.filePath = "$myAppStoragePath/${newPicture.fileId}.jpg";

    final pickedFile = await ImagePicker().getImage(source: source);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();

    File(newPicture.filePath).writeAsBytesSync(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    await _cropAndNavigate(newPicture, con);
  }

  _handleCameraButton(context) {
    var text =
        "Have your pet look straight at the camera.\n\nMouth should be visible and closed.";
    return showDialog(
        context: context,
        builder: (BuildContext ctx) =>
            photoDialog(text, ImageSource.camera, ctx));
  }

  _handleUploadButton(context) {
    var text = "Choose a head-on photo.\n\nMouth should be visible and closed.";
    return showDialog(
        context: context,
        builder: (BuildContext ctx) =>
            photoDialog(text, ImageSource.gallery, ctx));
  }

  photoDialog(String text, ImageSource imageSource, BuildContext context) {
    return CustomDialog(
      header: "For best results...",
      bodyText: text,
      primaryFunction: (BuildContext modalContext) {
        Navigator.of(modalContext).pop();
        getImage(imageSource, context);
      },
      secondaryFunction: (BuildContext modalContext) async {
        Navigator.of(modalContext).pop();
      },
      iconPrimary: Icon(
        Icons.camera_alt_outlined,
        size: 42,
        color: Colors.grey[300],
      ),
      iconSecondary: Icon(
        CustomIcons.modal_paws_topleft,
        size: 42,
        color: Colors.grey[300],
      ),
      isYesNo: false,
      primaryButtonText: "OK",
      secondaryButtonText: "Back",
    );
  }

  Widget build(BuildContext ctx) {
    con = ctx;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      appBar: CustomAppBar(noName: true),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(children: <Widget>[
                      Icon(LineAwesomeIcons.angle_left),
                      Text('Back'),
                    ]),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FlatButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            child:
                                Text("Camera", style: TextStyle(fontSize: 20)),
                            // color: Theme.of(context).primaryColor,
                            onPressed: () => _handleCameraButton(context),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            child:
                                Text("Upload", style: TextStyle(fontSize: 20)),
                            // color: Theme.of(context).primaryColor,
                            onPressed: () => _handleUploadButton(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(40)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
