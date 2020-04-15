import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
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
  Picture mountedPicture;

  mountPicture(picture) {
    this.mountedPicture = picture;
  }

  Picture findById(String id) {
    return all.firstWhere((test) {
      return test.fileId == id;
    });
  }

  String mountedPictureFileId() {
    return mountedPicture == null ? null : mountedPicture.fileId;
  }

  void add(Picture picture) {
    all.insert(0, picture);
    // notifyListeners();
  }

  void remove(picture) {
    try {
      deleteImageFromServer(picture);
    } catch (e) {
      print(e);
      return;
    }
    all.remove(picture);
    File(picture.filePath).delete();
    notifyListeners();
  }

  Future retrieveAll() async {
    String response = await retrieveAllImagesFromServer();
    json.decode(response).forEach((serverImage) async {
      if (serverImage["hidden"] == 1) return;
      if (serverImage["uuid"] == null) return;

      Picture pic = Picture(
          name: serverImage["name"],
          // SERVER IS NOT PROVIDING A FILE URL ATM....
          // fileUrl: serverImage["bucket_fp"],
          fileId: serverImage["uuid"],
          coordinates: serverImage["coordinates"]);
      if (all.indexWhere((pic) => pic.fileId == serverImage["uuid"]) == -1) {
        pic.fileUrl = "images/${pic.fileId}.jpg";
        await downloadAllImagesFromBucket([pic]);
        add(pic);
        notifyListeners();
      }
    });
  }

  Future downloadAllImagesFromBucket([List images]) async {
    Bucket bucket = await accessBucket();
    images = images == null ? all : images;
    int imagesCount = images.length;
    for (var i = 0; i < imagesCount; i++) {
      String filePath = await downloadFromBucket(
          images[i].fileUrl, images[i].fileId,
          image: true, bucket: bucket);
      images[i].filePath = filePath;
    }
  }
}

class Picture with ChangeNotifier, RestAPI, Gcloud {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String coordinates;
  bool creationAnimation;
  
  Picture(
      {String name,
      String filePath,
      String fileUrl,
      String fileId,
      String coordinates =
          "{'mouthOne': [], 'mouthTwo': [], 'mouthThree': [], 'rightEye': [0.4, 0.4], 'leftEye': [0.6, 0.4]}"}) {
    this.coordinates = coordinates;
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId == null ? Uuid().v4() : fileId;
    this.creationAnimation = true;
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

    destImage = IMG.copyResize(destImage, width: 800);
    var jpg = IMG.encodeJpg(destImage, quality: 80);

    File(filePath).deleteSync();
    await File(filePath).writeAsBytes(jpg);
  }
}
