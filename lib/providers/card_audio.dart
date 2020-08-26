import 'dart:io';

import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:uuid/uuid.dart';

class CardAudios with ChangeNotifier {
  List<CardAudio> all = [];

  CardAudio findById(id) {
    return all.firstWhere((audio) => audio.fileId == id);
  }

  Future<void> retrieveAll() async {
    var response = await RestAPI.retrieveAllDecorationImages();
    Bucket bucket = await Gcloud.accessBucket();

    response.forEach((imageData) {
      all.add(
        CardAudio(
          fileId: imageData["uuid"],
          bucketFp: imageData["bucket_fp"],
        ),
      );
      all.forEach((decoration) async {
        var filePath = "$myAppStoragePath/${decoration.fileId}.aac";
        if (File(filePath).existsSync()) return;
        await Gcloud.downloadFromBucket(decoration.bucketFp, filePath,
            bucket: bucket);
        decoration.filePath = filePath;
        decoration.amplitudes = await AmplitudeExtractor.getAmplitudes(filePath);
      });
    });
  }
}

class CardAudio{
  String fileId;
  String filePath;
  String bucketFp;
  List amplitudes;

  CardAudio({
    this.filePath,
    this.bucketFp,
    this.amplitudes,
    this.fileId
  }) {
    this.fileId ??= Uuid().v4();
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
