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

  String mountedPictureFileId() {
    return mountedPicture == null ? null : mountedPicture.fileId;
  }

  void add(Picture picture) {
    print("MouthCoordinates: ${picture.mouthCoordinates}");
    all.add(picture);
    notifyListeners();
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
    json.decode(response).forEach((serverImage) {
      if (serverImage["hidden"] == 1) return;
      if (serverImage["uuid"] == null) return;

      // print("INSIDE RETRIEVE ALL 1");
      // print(serverImage);
      // print("INSIDE RETRIEVE ALL 2");

      Picture pic = Picture(
          name: serverImage["name"],
          // SERVER IS NOT PROVIDING A FILE URL ATM....
          // fileUrl: serverImage["bucket_fp"],
          fileId: serverImage["uuid"],
          mouthCoordinates: serverImage["mouth_coordinates"]);
      if (all.indexWhere((pic) => pic.fileId == serverImage["uuid"]) == -1) {
        pic.fileUrl = "images/${pic.fileId}.jpg";
        add(pic);
      }
    });
    await downloadAllImagesFromBucket();
    notifyListeners();
  }

  Future downloadAllImagesFromBucket([List images]) async {
    images = images == null ? all : images;
    int imagesCount = images.length;
    for (var i = 0; i < imagesCount; i++) {
      String filePath =
          await downloadFromBucket(images[i].fileUrl, images[i].fileId, true);
      images[i].filePath = filePath;
      // print("downloadAllImagesFromBucket: ${json.encode(images[i])}");
    }
  }
}

class Picture with ChangeNotifier, RestAPI, Gcloud {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String mouthCoordinates;
  Picture(
      {String name,
      String filePath,
      String fileUrl,
      String fileId,
      String mouthCoordinates = "[(0.452, 0.415), (0.631, 0.334)]"}) {
    this.mouthCoordinates = mouthCoordinates;
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId == null ? Uuid().v4() : fileId;
    print(this);
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await uploadAsset(fileId, filePath, true);
    await createImageOnServer(this);
  }

  Future<void> crop() async {
    print("Inside Crop...before filePath: $filePath");
    var bytes = await File(filePath).readAsBytes();
    IMG.Image src = IMG.decodeImage(bytes);

    var cropSize = min(src.width, src.height);
    int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage =
        IMG.copyCrop(src, offsetX, offsetY, cropSize, cropSize);

    destImage = IMG.copyResize(destImage, width: 400);
    var jpg = IMG.encodeJpg(destImage, quality: 80);

    File(filePath).deleteSync();
    await File(filePath).writeAsBytes(jpg);
    print("Inside Crop...after filePath: $filePath");

  }
}
