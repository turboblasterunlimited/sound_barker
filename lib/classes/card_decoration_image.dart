import 'dart:io';

import 'package:image/image.dart' as IMG;
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:uuid/uuid.dart';

class CardDecorationImages {
  List<CardDecorationImage> all = [];

  retrieveAll() async {
    var response = await RestAPI.retrieveAllDecorationImages();

    response.forEach((imageData) {
      all.add(
        CardDecorationImage(
          fileId: imageData["uuid"],
          bucketFp: imageData["bucket_fp"],
        ),
      );
    });
  }
}

class CardDecorationImage {
  String fileId;
  String filePath;
  String bucketFp;

  CardDecorationImage({
    this.filePath,
    this.bucketFp,
    this.fileId,
  }) {
    this.fileId ??= Uuid().v4();
  }

  Future<void> delete() async {
    await RestAPI.deleteDecorationImage(fileId);
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }

  bool get hasFrameDimension {
    var bytes = File(filePath).readAsBytesSync();
    IMG.Image image = IMG.decodeImage(bytes);
    print("image width = ${image.width}");
    return image.width == 656;
  }
}
