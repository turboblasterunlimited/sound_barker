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
    String responseBody = await splitRawBark(fileId);
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

// var exampleResponse = {
//   "crops": [
//     {
//       "uuid": "11351e26-c976-4c41-aef3-bea759827b5d",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/11351e26-c976-4c41-aef3-bea759827b5d.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/11351e26-c976-4c41-aef3-bea759827b5d.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     },
//     {
//       "uuid": "c966b714-f983-4e82-a199-37c64880f9ab",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/c966b714-f983-4e82-a199-37c64880f9ab.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/c966b714-f983-4e82-a199-37c64880f9ab.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     },
//     {
//       "uuid": "e678aa6f-ac2c-46a2-b20c-889503e31e36",
//       "raw_id": "1d3204df-328e-4df0-8d8c-bd510e7fa65b",
//       "user_id": "tovi-id",
//       "name": null,
//       "bucket_url": "gs://1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/e678aa6f-ac2c-46a2-b20c-889503e31e36.aac",
//       "bucket_fp": "1d3204df-328e-4df0-8d8c-bd510e7fa65b/cropped/e678aa6f-ac2c-46a2-b20c-889503e31e36.aac",
//       "stream_url": null,
//       "hidden": 0,
//       "obj_type": "crop"
//     }
//   ],
//   "pet": {
//     "pet_id": 1,
//     "user_id": "tovi-id",
//     "name": "woofer",
//     "image_url": null,
//     "hidden": 0,
//     "obj_type": "pet"
//   }
// };