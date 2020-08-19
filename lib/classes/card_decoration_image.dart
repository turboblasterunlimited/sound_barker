import 'dart:io';

import 'package:K9_Karaoke/services/rest_api.dart';

class CardDecorationImage {
  String fileId;
  String filePath;
  String bucketFp;

  CardDecorationImage({
    this.fileId,
    this.filePath,
    this.bucketFp,
  });

  void delete() async {
    await RestAPI.deleteDecorationImage(fileId);
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }
}