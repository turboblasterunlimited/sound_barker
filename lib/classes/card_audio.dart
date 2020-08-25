import 'dart:io';

import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:uuid/uuid.dart';

class CardAudio {
  String fileId;
  String filePath;
  String bucketFp;
  List amplitudes;

  CardAudio({
    this.filePath,
    this.bucketFp,
    this.amplitudes,
  }) {
    this.fileId = Uuid().v4();
  }

  void deleteFile() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }

  Future<void> delete() async {
    print("Deleting old card audio");
    if (bucketFp != null) await RestAPI.deleteCardAudio(fileId);
    deleteFile();
  }
}
