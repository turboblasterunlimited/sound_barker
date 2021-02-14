import 'dart:convert';
import 'package:K9_Karaoke/globals.dart';
import 'package:K9_Karaoke/providers/asset.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier {
  List<Picture> all = [];
  List<Picture> stockPictures = [];

  void removeAll() {
    all = [];
    stockPictures = [];
  }

  List<Picture> get combinedPictures {
    return all + stockPictures;
  }

  Picture findById(String id) {
    return combinedPictures.firstWhere((picture) => picture.fileId == id);
  }

  void add(Picture picture) {
    all.insert(0, picture);
    notifyListeners();
  }

  Future<void> remove(picture) async {
    try {
      await RestAPI.deleteImage(picture);
    } catch (e) {
      print(e);
      return Future.delayed(Duration(seconds: 0));
    }
    all.remove(picture);
    picture.delete();
    notifyListeners();
  }

  void deleteAll() {
    all.forEach((picture) => picture.delete());
    stockPictures.forEach((picture) => picture.delete());
  }

  Future retrieveAll() async {
    List response = await RestAPI.retrieveAllImages();
    print("pictures: $response");
    response.forEach((serverImage) async {
      if (serverImage["hidden"] == 1) return;
      if (serverImage["uuid"] == null) return;

      Picture pic = Picture(
        isStock: serverImage["is_stock"] == 1 ? true : false,
        name: serverImage["name"],
        fileUrl: serverImage["bucket_fp"],
        fileId: serverImage["uuid"],
        coordinates: jsonDecode(serverImage["coordinates_json"].toString()),
        mouthColor: jsonDecode(serverImage["mouth_color"].toString()),
        lipColor: jsonDecode(serverImage["lip_color"].toString()),
        created: DateTime.parse(serverImage["created"]),
      );
      pic.isStock ? stockPictures.add(pic) : add(pic);
    });
    all.sort((pic1, pic2) {
      return pic1.created.compareTo(pic2.created);
    });

    stockPictures.sort((pic1, pic2) {
      return pic1.name.compareTo(pic2.name);
    });

    // Put the dog "Dean" 4th
    // temp fix to keep app from crashing, but no stock dogs will be displayed.
    if (stockPictures.isNotEmpty) {
      var deanIndex =
          stockPictures.indexWhere((element) => element.name == "Dean");
      var dean = stockPictures.removeAt(deanIndex);
      stockPictures.insert(3, dean);
    }
  }

  Future downloadAllImagesFromBucket([List<Picture> images]) async {
    images ??= all;
    int imagesCount = images.length;
    for (var i = 0; i < imagesCount; i++) {
      images[i].inferFilePath();
      if (!await File(images[i].filePath).exists())
        await Gcloud.downloadFromBucket(images[i].fileUrl, images[i].filePath);
    }
  }
}

class Picture extends Asset {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  Map<String, dynamic> coordinates;
  List mouthColor;
  List lipColor;
  double lipThickness;
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
    this.lipColor,
    this.lipThickness,
    this.created,
    this.isStock,
  }) {
    this.coordinates = coordinates ?? Map.of(defaultFaceCoordinates);
    this.mouthColor = mouthColor ?? [0.0, 0.0, 0.0];
    this.lipColor = lipColor ?? [0.0, 0.0, 0.0];
    this.lipThickness = lipThickness ?? 0.0;
    this.name = name ?? "Name";
    this.fileId = fileId ??= Uuid().v4();
    this.creationAnimation = true;
    this.isStock = isStock ?? false;
    inferFilePath();
  }

  bool get isNamed {
    return name != "Name";
  }

  void inferFilePath() {
    String fileName = fileId + '.jpg';
    this.filePath = myAppStoragePath + '/' + fileName;
  }

  void delete() {
    if (File(filePath).existsSync()) File(filePath).deleteSync();
  }

  void setName(String newName) {
    this.name = newName;
    RestAPI.updateImageName(this);
    notifyListeners();
  }

  Future<void> updateMouth(mouthColor, lipColor, lipThickness) async {
    mouthColor = mouthColor;
    lipColor = lipColor;
    lipThickness = lipThickness;
    await RestAPI.updateImage(this);
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await Gcloud.upload(filePath, "images");
    print("File url from uploadpictureandsavetoserver: $fileUrl");
    Map body = await RestAPI.createImage(this);
    created = DateTime.parse(body["created"]);
  }
}
