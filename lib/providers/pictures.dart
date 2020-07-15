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

  void initStockPictures() {
    // need to replace ids and filepaths with uuids
    List stockPictureData = [
      {
        "name": "Benjamin",
        "filePath": "assets/images/benjamin.jpg",
        "fileId": "benjamin",
        "coordinates": {
          "leftEye": [-0.1494140625, 0.08738878038194445],
          "rightEye": [0.2060546875, 0.08244086371527778],
          "mouth": [0.035400390625, -0.2714301215277778],
          "mouthLeft": [-0.0732421875, -0.3060574001736111],
          "mouthRight": [0.114013671875, -0.3026150173611111],
          "headTop": [0.0, 0.4],
          "headRight": [0.3, 0.0],
          "headBottom": [0.045654296875, -0.39380967881944445],
          "headLeft": [-0.3, 0.0],
          "mouthColor": [
            0.4666666666666667,
            0.3254901960784314,
            0.35294117647058826
          ]
        }
      },
      {
        "name": "Snow",
        "filePath": "assets/images/snow.jpg",
        "fileId": "snow",
        "coordinates": {
          "leftEye": [-0.2, 0.2],
          "rightEye": [0.2, 0.2],
          "mouth": [-0.004579518636067724, -0.24205881754557293],
          "mouthLeft": [-0.10457951863606772, -0.24205881754557293],
          "mouthRight": [0.09542048136393227, -0.24205881754557293],
          "headTop": [0.0, 0.4],
          "headRight": [0.3, 0.0],
          "headBottom": [0.0, -0.4],
          "headLeft": [-0.3, 0.0],
          "mouthColor": [
            0.3137254901960784,
            0.21568627450980393,
            0.23529411764705882
          ]
        }
      },
    ];
    stockPictureData.forEach((b) {
      var picture = Picture(
        name: b["name"],
        filePath: b["filePath"],
        fileId: b["uuid"],
        coordinates: b["coordinates"],
        isStock: true,
      );
      stockPictures.add(picture);
    });
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
        name: serverImage["name"],
        // SERVER IS NOT PROVIDING A FILE URL ATM....
        // fileUrl: serverImage["bucket_fp"],
        fileId: serverImage["uuid"],

        // need to use mouth_color instad of coordinates_json.
        // something is wrong with this
        coordinates: jsonDecode(serverImage["coordinates_json"]),
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
  Map<String, dynamic> coordinates;
  bool creationAnimation;
  DateTime created;
  bool isStock;

  Picture({
    this.name,
    this.filePath,
    this.fileUrl,
    this.fileId,
    this.coordinates,
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
          "mouthColor": [0.5686274509, 0.39607843137, 0.43137254902],
        };
    this.name = name ?? "Name";
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.creationAnimation = true;
    this.created = created;
    this.isStock = isStock ?? false;
  }

  List mouthColor() {
    return coordinates["mouthColor"];
  }

  void setName(String newName) {
    this.name = newName;
    RestAPI.updateImageOnServer(this);
    notifyListeners();
  }

  Future<void> updateMouthColor(color) async {
    coordinates["mouthColor"] = color;
    await RestAPI.updateImageOnServer(this);
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await Gcloud.uploadAsset(fileId, filePath, true);
    Map body = await RestAPI.createImageOnServer(this);
    created = DateTime.parse(body["created"]);
  }
}
