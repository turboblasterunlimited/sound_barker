import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Barks with ChangeNotifier {
  List<Bark> all = [];
  final listKey = GlobalKey<AnimatedListState>();

  void addBark(bark) {
    all.insert(0, bark);
    if (listKey.currentState != null) listKey.currentState.insertItem(0);
    // notifyListeners();
  }

  Future retrieveAll() async {
    String response = await RestAPI.retrieveAllBarksFromServer();
    print("parsed all barks: $response");

    json.decode(response).forEach((serverBark) async {
      if (serverBark["hidden"] == 1) return;
      Bark bark = Bark(
          name: serverBark["name"],
          fileUrl: serverBark["bucket_fp"],
          fileId: serverBark["uuid"],
          created:  DateTime.parse(serverBark["created"]));
      // if serverBark isn't already in in barks.all
      if (all.indexWhere(
              (bark) => bark.fileId == serverBark["uuid"].toString()) ==
          -1) {
        await downloadAllBarksFromBucket([bark]);
        addBark(bark);
      }
    });
    // await downloadAllBarksFromBucket();
    notifyListeners();
  }

  // downloads the files either from all barks in memory or just the barks passed.
  Future downloadAllBarksFromBucket([List barks]) async {
    Bucket bucket = await Gcloud.accessBucket();

    barks ??= null;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      // print(barks[i])
      String filePath =
          await Gcloud.downloadFromBucket(barks[i].fileUrl, barks[i].fileId);
      barks[i].filePath = filePath;
    }
    sortBarks();
  }

  sortBarks() {
    all.sort((bark1, bark2) {
      return bark2.created.compareTo(bark1.created);
    });
  }

  List get allBarks {
    return all;
  }

  void remove(barkToDelete) {
    barkToDelete.deleteFromServer();
    all.remove(barkToDelete);
    File(barkToDelete.filePath).delete();
    notifyListeners();
  }
}

class Bark with ChangeNotifier {
  String name;
  String fileUrl;
  String
      filePath; // This is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  String fileId;
  DateTime created;

  Bark(
      {String name,
      String filePath,
      String fileUrl,
      String fileId,
      DateTime created}) {
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.created = created ??= DateTime.now();
  }

  Future<String> rename(newName) async {
    try {
      await RestAPI.renameBarkOnServer(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  Future<String> deleteFromServer() {
    return RestAPI.deleteBarkFromServer(this);
  }

  Future<List> uploadBarkAndRetrieveCroppedBarks(imageId) async {
    var downloadLink = await Gcloud.uploadAsset(fileId, filePath, false);
    // downloadLink for rawBark is probably not needed.
    String responseBody = await RestAPI.splitRawBarkOnServer(fileId, imageId);
    List newBarks = parseCroppedBarks(responseBody);
    return newBarks;
  }

  List parseCroppedBarks(response) {
    print("parsed cropped barks: $response");
    List newBarks = [];
    List cloudBarkData = json.decode(response);
    int barkCount = cloudBarkData.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(Bark(
        fileId: cloudBarkData[i]["uuid"],
        name: cloudBarkData[i]["name"],
        fileUrl: cloudBarkData[i]["bucket_fp"],
        created: DateTime.parse(cloudBarkData[i]["created"]),
      ));

    }
    return newBarks;
  }
}
