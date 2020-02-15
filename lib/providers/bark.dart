import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Bark with ChangeNotifier {
  String _name;
  String fileUrl;
  final String
      filePath; // This is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  final String fileId = Uuid().v4();
  String petId;

  Bark(
    this.petId,
    this._name,
    this.filePath,
  );

  String get name {
    return _name;
  }

  void playBark() {}

  Future<Bucket> accessBucket() async {
    var credData =
        await rootBundle.loadString('credentials/gcloud_credentials.json');
    var credentials = auth.ServiceAccountCredentials.fromJson(credData);
    List<String> scopes = []..addAll(Storage.SCOPES);

    auth.AutoRefreshingAuthClient client =
        await auth.clientViaServiceAccount(credentials, scopes);
    var storage = Storage(client, 'songbarker');
    return storage.bucket('song_barker_sequences');
  }

  Future<Bark> uploadBark() async {
    var info;
    Bucket bucket = await accessBucket();
    try {
      info =
          await File(filePath).openRead().pipe(bucket.write("$fileId/raw.aac"));
    } catch (error) {
      print('failed to put bark in the bucket');
      return error;
    }
    print(info.downloadLink);
    await notifyServer();
    await Future.delayed(
        Duration(seconds: 2), () => print('done')); // This is temporary.
    String response = await splitAudio();
    print("One Bark Path: ${retrieveCroppedBarks(response)}");
    return this;
  }

  Future<String> splitAudio() async {
    http.Response response;
    // User ID hardcoded as 999 for now. This should be a post request in the future.
    final url = 'http://165.227.178.14/split_audio';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'uuid': fileId,
        }),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );
    } catch (error) {
      print(error);
      throw error;
    }
    print("REsponse content: ${response.body}. ResPONSE.body TYPE: ${response.body.runtimeType}");
    return response.body;
  }

  Future<void> notifyServer() async {
    http.Response response;
    // User ID hardcoded as 999 for now. This should be a post request in the future.
    final url = 'http://165.227.178.14/add_raw';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'client_id': '999',
          'name': _name,
          'uuid': fileId,
          'pet_id': petId,
        }),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      );
    } catch (error) {
      print(error);
      throw error;
    }
    // print(response.body.toString());
  }

  String retrieveCroppedBarks(response) {
    var oneBarkPath = json.decode(json.encode(response))["rows"][0]["url"];
    return oneBarkPath;
  }
}

// var exampleResponse = {
//   "rows": [
//     {
//       "obj_type": "crop",
//       "uuid": "4572cfbb-cc0b-48d3-b43a-8fb726002300",
//       "url":
//           "gs://de9add42-afa1-4304-8bb1-0bff374ad5f2/cropped/4572cfbb-cc0b-48d3-b43a-8fb726002300.wav"
//     },
//     {
//       "obj_type": "crop",
//       "uuid": "7f75daed-ef29-46f5-900c-b162324e2fe5",
//       "url":
//           "gs://de9add42-afa1-4304-8bb1-0bff374ad5f2/cropped/7f75daed-ef29-46f5-900c-b162324e2fe5.wav"
//     },
//     {
//       "obj_type": "crop",
//       "uuid": "41754516-8a6d-446c-84e3-bf0711108e90",
//       "url":
//           "gs://de9add42-afa1-4304-8bb1-0bff374ad5f2/cropped/41754516-8a6d-446c-84e3-bf0711108e90.wav"
//     },
//     {
//       "obj_type": "crop",
//       "uuid": "e8f25e15-4eee-4019-921b-45173c3c78ec",
//       "url":
//           "gs://de9add42-afa1-4304-8bb1-0bff374ad5f2/cropped/e8f25e15-4eee-4019-921b-45173c3c78ec.wav"
//     }
//   ]
// };
