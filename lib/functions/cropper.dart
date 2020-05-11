import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

Future<void> cropImage(newPicture, toolbarColor, widgetColor) async {
  File newFile = await ImageCropper.cropImage(
    sourcePath: newPicture.filePath,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Now crop it!',
        toolbarColor: toolbarColor,
        toolbarWidgetColor: widgetColor,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: false),
    iosUiSettings: IOSUiSettings(
      title: 'Now crop it!',
    ),
  );
  // Replace old file
  File(newPicture.filePath).deleteSync();
  newFile.copy(newPicture.filePath);
}
