import 'dart:io';

import 'package:K9_Karaoke/services/rest_api.dart';

class CardAudio {
  String fileId;
  String filePath;
  String bucketFp;
  List amplitudes;

  CardAudio({
    this.fileId,
    this.filePath,
    this.bucketFp,
    this.amplitudes,
  });

  void delete() async {
    await RestAPI.deleteCardAudio(fileId);
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }
}
