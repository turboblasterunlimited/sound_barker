import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier {
  List<Picture> all = [];

  Picture findById(String id) {
    return all.firstWhere((test) {
      return test.fileId == id;
    });
  }

  void add(Picture picture) {
    all.insert(0, picture);
    notifyListeners();
  }

  dynamic remove(picture) {
    try {
      RestAPI.deleteImageFromServer(picture);
    } catch (e) {
      print(e);
      return;
    }
    all.remove(picture);
    File(picture.filePath).delete();
    notifyListeners();
  }

  Future<Picture> retrieveAll() async {
    List tempPics = [];
    List response = await RestAPI.retrieveAllImagesFromServer();
    response.forEach((serverImage) async {
      if (serverImage["hidden"] == 1) return;
      if (serverImage["uuid"] == null) return;

      Picture pic = Picture(
        name: serverImage["name"],
        // SERVER IS NOT PROVIDING A FILE URL ATM....
        // fileUrl: serverImage["bucket_fp"],
        fileId: serverImage["uuid"],
        coordinates: serverImage["coordinates_json"],
        created: DateTime.parse(serverImage["created"]),
      );
      pic.fileUrl = "images/${pic.fileId}.jpg";
      tempPics.add(pic);
    });
    await downloadAllImagesFromBucket(tempPics);
    tempPics.sort((bark1, bark2) {
      return bark1.created.compareTo(bark2.created);
    });
    tempPics.forEach((pic) {
      add(pic);
    });
    // Important
    if (tempPics.isEmpty) return null;
    notifyListeners();
  }

  Future downloadAllImagesFromBucket([List images]) async {
    Bucket bucket = await Gcloud.accessBucket();
    images ??= all;
    int imagesCount = images.length;
    for (var i = 0; i < imagesCount; i++) {
      String fileName = images[i].fileId + '.jpg';
      String filePath = myAppStoragePath + '/' + fileName;
      images[i].filePath = filePath;
      if (!await File(filePath).exists())
        await Gcloud.downloadFromBucket(images[i].fileUrl, fileName,
            bucket: bucket);
    }
  }
}

class Picture with ChangeNotifier, Gcloud {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String coordinates;
  bool creationAnimation;
  DateTime created;

  Picture({
    String name,
    String filePath,
    String fileUrl,
    String fileId,
    String coordinates = "{}",
    DateTime created,
  }) {
    this.coordinates = coordinates;
    this.name = "Name";
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.creationAnimation = true;
    this.created = created;
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await Gcloud.uploadAsset(fileId, filePath, true);
    Map body = await RestAPI.createImageOnServer(this);
    created = DateTime.parse(body["created"]);
  }
}
