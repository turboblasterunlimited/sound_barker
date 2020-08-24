import 'dart:io';

import 'package:image/image.dart' as IMG;
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:uuid/uuid.dart';

class CardDecorationImage {
  String fileId;
  String filePath;
  String bucketFp;

  CardDecorationImage({
    this.filePath,
    this.bucketFp,
  }) {
    this.fileId = Uuid().v4();
  }

  void delete() async {
    await RestAPI.deleteDecorationImage(fileId);
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }

  Future<bool> get hasFrameDimension async {
    var bytes = await File(filePath).readAsBytes();
    IMG.Image image = IMG.decodeImage(bytes);
    print("image width = ${image.width}");
    return image.width != 656;
  }
}
