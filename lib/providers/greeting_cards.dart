import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as IMG;
import 'dart:convert';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class GreetingCards with ChangeNotifier {
  List<GreetingCard> all = [];

  void add(GreetingCard card) {
    all.insert(0, card);
    // notifyListeners();
  }

  void remove(card) {
    all.remove(card);
    File(card.filePath).delete();
    notifyListeners();
  }

  Future retrieveAll() async {
    // Implement local state preservation
  }
}

class GreetingCard with ChangeNotifier {
  String name;
  String filePath;
  String fileId;
  bool creationAnimation;
  GreetingCard({
    String name,
    String filePath,
    String fileId,
  }) {
    this.name = name;
    this.filePath = filePath;
    this.fileId ??= Uuid().v4();
    this.creationAnimation = true;
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
