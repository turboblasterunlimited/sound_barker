import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

Future<void> cropImage(newPicture, toolbarColor, widgetColor) async {
  await ImageCropper.cropImage(
      sourcePath: newPicture.filePath,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
            ]
          : [
              CropAspectRatioPreset.square,
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Now crop it!',
          toolbarColor: toolbarColor,
          toolbarWidgetColor: widgetColor,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Now crop it!',
      ));
}
