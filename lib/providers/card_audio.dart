import 'dart:io';

import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CardAudios with ChangeNotifier {
  List<CardAudio> all = [];

  CardAudio findById(id) {
    var result;
    try {
      result = all.firstWhere((audio) => audio.fileId == id);
    } catch (e) {
      print("Error! CardAudio id: $id not found!!");
    }
    return result ?? CardAudio();
  }

  Future<void> retrieveAll() async {
    var response = await RestAPI.retrieveAllCardAudio();

    response.forEach((audioData) {
      if (audioData["hidden"] == 1) return;
      all.add(CardAudio(
          fileId: audioData["uuid"], bucketFp: audioData["bucket_fp"]));
    });

    await Future.wait(all.map((audio) async {
      var filePath = "$myAppStoragePath/${audio.fileId}.aac";
      audio.filePath = filePath;

      // print("file length: ${File(filePath).lengthSync()}");

      if (!File(filePath).existsSync())
        await Gcloud.downloadFromBucket(audio.bucketFp!, filePath);
    }));
    notifyListeners();
  }
}

class CardAudio {
  String? fileId;
  String? filePath;
  String? bucketFp;
  List? amplitudes;

  CardAudio({this.filePath, this.bucketFp, this.amplitudes, this.fileId}) {
    this.fileId ??= Uuid().v4();
  }

  bool get exists {
    return filePath != null && File(filePath!).existsSync();
  }

  void deleteFile() {
    if (File(filePath!).existsSync()) File(filePath!).deleteSync();
  }

  Future<void> delete() async {
    print("Deleting old card audio");
    try {
      if (bucketFp != null) await RestAPI.deleteCardAudio(fileId!);
      deleteFile();
      amplitudes = null;
      filePath = null;
      fileId = null;
      bucketFp = null;
    } catch (e) {
      print(e);
    }
  }
}
