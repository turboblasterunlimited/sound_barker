import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as IMG;
import 'dart:convert';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier, Gcloud, RestAPI {
  List<Picture> all = [];

  void add(Picture picture) {
    all.add(picture);
    notifyListeners();
  }

  void remove(picture) {
    all.remove(picture);
    notifyListeners();
  }

  Future retrieveAll() async {
    String response = await retrieveAllImagesFromServer();
    json.decode(response).forEach((serverImage) {
      if (serverImage["hidden"] == 1) return;
      Picture bark = Picture(
          name: serverImage["name"],
          fileUrl: serverImage["bucket_fp"],
          fileId: serverImage["uuid"]);
      if (all.indexWhere((bark) => bark.fileId == serverImage["uuid"]) == -1) {
        all.add(bark);
      }
    });
    await downloadAllImagesFromBucket();
    notifyListeners();
  }

  Future downloadAllImagesFromBucket([List images]) async {
    images = images == null ? all : images;
    int barkCount = images.length;
    for (var i = 0; i < barkCount; i++) {
      String filePath = await downloadFromBucket(
          images[i].fileUrl, images[i].fileId,
          true);
      images[i].filePath = filePath;
    }
  }
}

class Picture with ChangeNotifier, RestAPI, Gcloud {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  Picture({String name, String filePath, String fileUrl, String fileId}) {
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId == null ? Uuid().v4() : fileId;
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await uploadAsset(fileId, filePath, true);
    await createImageOnServer(this);
  }

  Future<void> crop() async {
    var bytes = await File(filePath).readAsBytes();
    IMG.Image src = IMG.decodeImage(bytes);

    var cropSize = min(src.width, src.height);
    int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage =
        IMG.copyCrop(src, offsetX, offsetY, cropSize, cropSize);

    var jpg = IMG.encodeJpg(destImage);

    File(filePath).deleteSync();
    await File(filePath).writeAsBytes(jpg);
  }
}
