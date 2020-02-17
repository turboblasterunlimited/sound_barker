import 'package:gcloud/storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './gcloud.dart';
import './rest_api.dart';

class Barks with ChangeNotifier {
  List<Bark> all = [];

  void addBark(bark) {
    all.add(bark);
    notifyListeners();
    print("All the barks: $all");
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

  // void playBark() async {
  //   Bucket bucket = await accessBucket();
  //   try {
  //     bucket.read("");
  //   } catch (error) {
  //     print('failed to put bark in the bucket');
  //     return error;
  //   }
  // }

  Future <List<Bark>> uploadBarkAndRetrieveCroppedBarks() async {
    var downloadLink = uploadRawBark(fileId, filePath);
    // downloadLink for rawBark is probably not needed.
    print(downloadLink);
    await notifyServerRawBarkInBucket(fileId, petId);
    await Future.delayed(
        Duration(seconds: 2), () => print('done')); // This is temporary.
    String responseBody = await splitRawBarkOnServer(fileId);
    print("Response body content: $responseBody");
    List<Bark> newBarks = retrieveCroppedBarks(responseBody);
    return newBarks;
  }



  List<Bark> retrieveCroppedBarks(response) {
    print(response);
    List newBarks = [];
    Map responseData = json.decode(response);
    Map cloudBarkData = responseData["crops"];
    String petId = responseData["pet"]["pet_id"];
    int barkCount = cloudBarkData.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(Bark(
        fileId: cloudBarkData["uuid"],
        petId: petId,
        name: cloudBarkData["name"],
        fileUrl: cloudBarkData["bucket_fp"]
      ));
    }
    return newBarks;
  }
}
