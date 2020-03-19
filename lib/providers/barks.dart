import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Barks with ChangeNotifier, Gcloud, RestAPI {
  List<Bark> all = [];

  void addBark(bark) {
    all.insert(0, bark);
    notifyListeners();
    //print("All the barks: $all");
  }

  Future retrieveAll() async {
    String response = await retrieveAllBarksFromServer();
    json.decode(response).forEach((serverBark) {
      if(serverBark["hidden"] == 1) return;
      Bark bark = Bark(name: serverBark["name"], fileUrl: serverBark["bucket_fp"], fileId: serverBark["uuid"]);
      if (all.indexWhere((bark) => bark.fileId == serverBark["uuid"]) == -1) {
        all.add(bark);
      }
    });
    await downloadAllBarksFromBucket();
    notifyListeners();
  }

  Future downloadAllBarksFromBucket([List barks]) async {
    barks = barks == null ? all : barks;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      String filePath =
          await downloadFromBucket(barks[i].fileUrl, barks[i].fileId, false);
      barks[i].filePath = filePath;
    }
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

class Bark with ChangeNotifier, Gcloud, RestAPI {
  String name;
  String fileUrl;
  String
      filePath; // This is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  String fileId;

  Bark({String name, String filePath, String fileUrl, String fileId}) {
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId == null ? Uuid().v4() : fileId;
  }

  Future<String> rename(newName) async {
    try {
      await renameBarkOnServer(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  Future<String> deleteFromServer() {
    return deleteBarkFromServer(this);
  }

  Future<String> createSongOnServerAndRetrieve(songId) async {
    String response = await createSong(fileId, songId);
    return response;
  }

  Future<List> uploadBarkAndRetrieveCroppedBarks(imageId) async {
    var downloadLink = await uploadAsset(fileId, filePath, false);
    // downloadLink for rawBark is probably not needed.
    //print(downloadLink);
    String responseBody = await splitRawBarkOnServer(fileId, imageId);
    //print("Response body content: $responseBody");
    List newBarks = parseCroppedBarks(responseBody);
    return newBarks;
  }

  List parseCroppedBarks(response) {
    //print(response);
    List newBarks = [];
    List cloudBarkData = json.decode(response);
    int barkCount = cloudBarkData.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(Bark(
        fileId: cloudBarkData[i]["uuid"],
        name: cloudBarkData[i]["name"],
        fileUrl: cloudBarkData[i]["bucket_fp"],
      ));
    }
    return newBarks;
  }
}
