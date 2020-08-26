import 'dart:io';

import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:image/image.dart' as IMG;
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as PATH;

class CardDecorationImages with ChangeNotifier {
  List<CardDecorationImage> all = [];

  CardDecorationImage findById(id) {
    return all.firstWhere((decoration) => decoration.fileId == id);
  }

  Future<void> retrieveAll() async {
    var response = await RestAPI.retrieveAllDecorationImages();
    Bucket bucket = await Gcloud.accessBucket();

    response.forEach((imageData) {
      all.add(
        CardDecorationImage(
          fileId: imageData["uuid"],
          bucketFp: imageData["bucket_fp"],
        ),
      );
      all.forEach((decoration) async {
        var filePath = "$myAppStoragePath/${decoration.fileId}.png";
        if (File(filePath).existsSync()) return;
        await Gcloud.downloadFromBucket(decoration.bucketFp, filePath,
            bucket: bucket);
        decoration.filePath = filePath;
      });
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
    return image.width == 656;
  }
}
