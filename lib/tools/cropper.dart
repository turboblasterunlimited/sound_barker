import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as IMG;

Future<void> resizeImage(filePath) async {
  var bytes = await File(filePath).readAsBytes();
  IMG.Image src = IMG.decodeImage(bytes);
  var destImage = IMG.copyResize(src, width: 512, height: 512);
  var jpg = IMG.encodeJpg(destImage, quality: 90);
  await File(filePath).writeAsBytes(jpg);
}

Future<bool> cropImage(picture, toolbarColor, widgetColor) async {
  File newFile = await ImageCropper.cropImage(
    sourcePath: picture.filePath,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 80,
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
  print("Rename File: ${picture.filePath}");
  if (newFile == null) return false;
  newFile.renameSync(picture.filePath);
  // make it 512x512
  await resizeImage(picture.filePath);
  return true;
}
