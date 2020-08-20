import 'dart:io';

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
}