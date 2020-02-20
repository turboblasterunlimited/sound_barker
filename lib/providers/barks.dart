import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Barks with ChangeNotifier, Gcloud {
  List<Bark> all = [];

  void addBark(bark) {
    all.add(bark);
    notifyListeners();
    //print("All the barks: $all");
  }

  void downloadAllBarksFromBucket([List barks]) async {
    barks = barks == null ? all : barks;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      String filePath =
          await downloadSoundFromBucket(barks[i].fileUrl, barks[i].fileId);
      barks[i].filePath = filePath;
      //print("filePath for crop: $filePath");
    }
  }
  
  List get allBarks {
    return all;
  }

  void removeBark(barkToDelete) {
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
  String petId;

  Bark({petId, name, filePath, fileUrl, fileId}) {
    this.petId = petId;
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId == null ? Uuid().v4() : fileId;
  }

  

  void rename(name) {
    this.name = name;
    notifyListeners();
  }

  Future<String> renameOnServer() {
    return renameBarkOnServer(this);
  }

  Future<String> deleteFromServer() {
    return deleteBarkFromServer(this);
  }

  Future<String> createSongOnServerAndRetrieve() async {
    String response = await createSong(fileId, "happy birthday", petId);
    return response;
  }

  Future<List> uploadBarkAndRetrieveCroppedBarks() async {
    var downloadLink = uploadRawBark(fileId, filePath);
    // downloadLink for rawBark is probably not needed.
    //print(downloadLink);
    await notifyServerRawBarkInBucket(fileId, petId);
    await Future.delayed(
        Duration(seconds: 1), () => print('done')); // This is temporary.
    String responseBody = await splitRawBarkOnServer(fileId, petId);
    //print("Response body content: $responseBody");
    List newBarks = retrieveCroppedBarks(responseBody);
    return newBarks;
  }

  List retrieveCroppedBarks(response) {
    //print(response);
    List newBarks = [];
    Map responseData = json.decode(response);
    List cloudBarkData = responseData["crops"];
    String petId = responseData["pet"]["pet_id"].toString();
    int barkCount = cloudBarkData.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(Bark(
        fileId: cloudBarkData[i]["uuid"],
        petId: petId,
        name: cloudBarkData[i]["name"],
        fileUrl: cloudBarkData[i]["bucket_fp"],
      ));
    }
    return newBarks;
  }
}
