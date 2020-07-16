import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier {
  List<Picture> all = [];
  List<Picture> stockPictures = [];

  List<Picture> get combinedPictures {
    return all + stockPictures;
  }

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
        isStock: serverImage["is_stock"],
        name: serverImage["name"],
        fileUrl: serverImage["bucket_fp"],
        fileId: serverImage["uuid"],
        // something is wrong with this
        coordinates: jsonDecode(serverImage["coordinates_json"].toString()),
        mouthColor: jsonDecode(serverImage["mouth_color"]),
        created: DateTime.parse(serverImage["created"]),
      );
      print("imageUrl: ${pic.fileUrl}");
      tempPics.add(pic);
    });
    await downloadAllImagesFromBucket(tempPics);
    tempPics.sort((bark1, bark2) {
      return bark1.created.compareTo(bark2.created);
    });
    tempPics.forEach((pic) {
      pic.isStock ? stockPictures.add(pic) : add(pic);
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
  Map<String, dynamic> coordinates;
  List mouthColor;
  bool creationAnimation;
  DateTime created;
  bool isStock;

  Picture({
    this.name,
    this.filePath,
    this.fileUrl,
    this.fileId,
    this.coordinates,
    this.mouthColor,
    this.created,
    this.isStock,
  }) {
    this.coordinates = coordinates ??
        {
          "leftEye": [-0.2, 0.2],
          "rightEye": [0.2, 0.2],
          "mouth": [0.0, 0.0],
          "mouthLeft": [-0.1, 0.0],
          "mouthRight": [0.1, 0.0],
          "headTop": [0.0, 0.4],
          "headRight": [0.3, 0.0],
          "headBottom": [0.0, -0.4],
          "headLeft": [-0.3, 0.0],
        };
    this.mouthColor = mouthColor ?? [0.60392156, 0.12549019607, 0.12549019607];
    this.name = name ?? "Name";
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.creationAnimation = true;
    this.created = created;
    this.isStock = isStock ?? false;
  }

  void setName(String newName) {
    this.name = newName;
    RestAPI.updateImageOnServer(this);
    notifyListeners();
  }

  Future<void> updateMouthColor(color) async {
    mouthColor = color;
    await RestAPI.updateImageOnServer(this);
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await Gcloud.uploadAsset(fileId, filePath, true);
    Map body = await RestAPI.createImageOnServer(this);
    created = DateTime.parse(body["created"]);
  }
}
