import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as IMG;

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier, Gcloud {
  List<Picture> all = [
    // iOS Pictures
    // Picture(
    //     filePath:
    //         "/Users/tovinewman/Library/Developer/CoreSimulator/Devices/3FD6B298-8ED0-40F2-955F-5C12BB3D6AB4/data/Containers/Data/Application/27E1B6B2-219E-480F-8E0D-0B0B4AAD9E4A/Documents/drrudo.png",
    //     name: "dr. rudo"),
    // Picture(
    //     filePath:
    //         "/Users/tovinewman/Library/Developer/CoreSimulator/Devices/3FD6B298-8ED0-40F2-955F-5C12BB3D6AB4/data/Containers/Data/Application/27E1B6B2-219E-480F-8E0D-0B0B4AAD9E4A/Documents/dog.jpg",
    //     name: "dog"),

    // Android Pictures
    // Picture(
    //     filePath:
    //         "/data/user/0/com.example.song_barker/cache/2020-03-06 14:02:14.359453",
    //     name: "couch"),
    // Picture(
    //     filePath:
    //         "/data/user/0/com.example.song_barker/cache/2020-03-06 13:52:09.254723",
    //     name: "door"),
    // Picture(
    //     filePath:
    //         "/data/user/0/com.example.song_barker/cache/2020-03-06 14:03:25.095228",
    //     name: "window")
  ];

  void add(Picture picture) {
    all.add(picture);
    notifyListeners();
  }

  void remove(picture) {
    all.remove(picture);
    notifyListeners();
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
    this.fileUrl = await uploadPicture(fileId, filePath);
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
