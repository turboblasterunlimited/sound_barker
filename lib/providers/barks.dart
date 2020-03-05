import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Barks with ChangeNotifier, Gcloud, RestAPI {
  List<Bark> all = [];

  void addBark(bark) {
    all.add(bark);
    notifyListeners();
    //print("All the barks: $all");
  }

  Future retrieveAllBarks() async {
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
          await downloadSoundFromBucket(barks[i].fileUrl, barks[i].fileId);
      barks[i].filePath = filePath;
    }
  }

  List get allBarks {
    return all;
  }

  void removeBark(barkToDelete) {
    barkToDelete.removeFromStorage();
    all.removeWhere((bark) {
      return bark.fileId == barkToDelete.fileId;
    });
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

  void removeFromStorage() {
    try {
      File(filePath).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<String> rename(name) async {
    try {
      await renameBarkOnServer(this);
    } catch (e) {
      throw e;
    }
    this.name = name;
    notifyListeners();
  }

  Future<String> deleteFromServer() {
    return deleteBarkFromServer(this);
  }

  Future<String> createSongOnServerAndRetrieve() async {
    String response = await createSong(fileId, "happy birthday");
    return response;
  }

  Future<List> uploadBarkAndRetrieveCroppedBarks() async {
    var downloadLink = uploadRawBark(fileId, filePath);
    // downloadLink for rawBark is probably not needed.
    //print(downloadLink);
    await notifyServerRawBarkInBucket(fileId, 'imageName');
    // await Future.delayed(
    //     Duration(seconds: 1), () => print('done')); // This is temporary.
    String responseBody = await splitRawBarkOnServer(fileId, 'imageName');
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
