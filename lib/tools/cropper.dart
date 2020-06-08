import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as IMG;

  Future<void> resizeImage(filePath) async {
    var bytes = await File(filePath).readAsBytes();
    IMG.Image src = IMG.decodeImage(bytes);

    var destImage = IMG.copyResize(src, width: 512, height: 512);
    var jpg = IMG.encodeJpg(destImage, quality: 90);

    File(filePath).deleteSync();
    await File(filePath).writeAsBytes(jpg);
  }

Future<void> cropImage(newPicture, toolbarColor, widgetColor) async {
  File newFile = await ImageCropper.cropImage(
    sourcePath: newPicture.filePath,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 100,
    androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Now crop it!',
        toolbarColor: toolbarColor,
        toolbarWidgetColor: widgetColor,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true),
    iosUiSettings: IOSUiSettings(
      aspectRatioLockDimensionSwapEnabled: true,
      title: 'Now crop it!',
    ),
  );

  resizeImage(newFile.path);

  // Replace old file
  newFile.rename(newPicture.filePath);
}
