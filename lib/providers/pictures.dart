import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pictures with ChangeNotifier, Gcloud {
  List<Picture> all = [];

  void add(Picture picture) {
    all.add(picture);
  }

}

class Picture with ChangeNotifier {
  String name;
  String filePath;
  Picture({this.filePath, this.name});
}