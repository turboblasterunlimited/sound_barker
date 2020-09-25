import 'dart:io';

import 'package:K9_Karaoke/services/gcloud.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;
import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:uuid/uuid.dart';

class CardDecorationImages with ChangeNotifier {
  List<CardDecorationImage> all = [];

  CardDecorationImage findById(id) {
    var result;
    try {
      result = all.firstWhere((decoration) => decoration.fileId == id);
    } catch (e) {
      print(e);
      return null;
    }
    return result;
  }

  Future<void> retrieveAll() async {
    var response = await RestAPI.retrieveAllDecorationImages();
    String lastDecorationImage;

    response.forEach((imageData) {
      if (imageData["hidden"] == 1) return;
      all.add(
        CardDecorationImage(
          fileId: imageData["uuid"],
          bucketFp: imageData["bucket_fp"],
          frameDimension: imageData["has_frame_dimension"] == 1 ? true : false,
        ),
      );
    });
    await Future.wait(
      all.map(
        (decoration) async {
          var filePath = "$myAppStoragePath/${decoration.fileId}.png";
          decoration.filePath = filePath;

          if (File(filePath).existsSync()) return;
          try {
            await Gcloud.downloadFromBucket(decoration.bucketFp, filePath);
          } catch (e) {
            // hack to get around bad bucket_fp
            print(e);
            filePath = lastDecorationImage;
          }
          lastDecorationImage = filePath;
        },
      ),
    );
    notifyListeners();
  }
}

class CardDecorationImage {
  String fileId;
  String filePath;
  String bucketFp;
  bool frameDimension;

  CardDecorationImage({
    this.filePath,
    this.bucketFp,
    this.fileId,
    this.frameDimension,
  }) {
    this.fileId ??= Uuid().v4();
  }

  bool get exists {
    return filePath != null;
  }

  Future<void> delete() async {
    await RestAPI.deleteDecorationImage(fileId);
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }

  bool get hasFrameDimension {
    // 656 with frame. 512 without.
    if (frameDimension != null) return frameDimension;
    var bytes = File(filePath).readAsBytesSync();
    IMG.Image image = IMG.decodeImage(bytes);
    frameDimension = image.width == 656;
    return frameDimension;
  }
}
