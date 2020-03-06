import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier, Gcloud {
  List<Picture> all = [
    Picture(
        filePath:
            "/data/user/0/com.example.song_barker/cache/2020-03-06 14:02:14.359453",
        name: "couch"),
    Picture(
        filePath:
            "/data/user/0/com.example.song_barker/cache/2020-03-06 13:52:09.254723",
        name: "door"),
    Picture(
        filePath:
            "/data/user/0/com.example.song_barker/cache/2020-03-06 14:03:25.095228",
        name: "window")
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

class Picture with ChangeNotifier {
  String name;
  String filePath;
  Picture({this.filePath, this.name});
}
