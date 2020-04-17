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

class Pictures with ChangeNotifier {
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
      RestAPI.deleteImageFromServer(picture);
    } catch (e) {
      print(e);
      return;
    }
    all.remove(picture);
    File(picture.filePath).delete();
    notifyListeners();
  }

  Future retrieveAll() async {
    String response = await RestAPI.retrieveAllImagesFromServer();
    json.decode(response).forEach((serverImage) async {
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
      // THIS NEEDS ATTENTION.
      if (all.indexWhere((pic) => pic.fileId == serverImage["uuid"]) == -1) {
        pic.fileUrl = "images/${pic.fileId}.jpg";
        await downloadAllImagesFromBucket([pic]);
        add(pic);
        notifyListeners();
      }
    });
    sortImages();
  }

  sortImages() {
    all.sort((image1, image2) => image1.created.compareTo(image2.created));
  }

  Future downloadAllImagesFromBucket([List images]) async {
    Bucket bucket = await Gcloud.accessBucket();
    images ??= all;
    int imagesCount = images.length;
    for (var i = 0; i < imagesCount; i++) {
      String filePath = await Gcloud.downloadFromBucket(
          images[i].fileUrl, images[i].fileId,
          image: true, bucket: bucket);
      images[i].filePath = filePath;
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
    String coordinates = '{"rightEye": [-0.2, 0.2], "leftEye": [0.2, 0.2]}',
        // "mouthOne": [-0.1, -0.2], "mouthTwo": [0, -0.22], "mouthThree": [0.1, -0.2], 
    DateTime created,
  }) {
    this.coordinates = coordinates;
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.creationAnimation = true;
    this.created = created;
  }

  Future<void> uploadPictureAndSaveToServer() async {
    this.fileUrl = await Gcloud.uploadAsset(fileId, filePath, true);
    String response = await RestAPI.createImageOnServer(this);
    Map body = json.decode(response);
    created = DateTime.parse(body["created"]);
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
