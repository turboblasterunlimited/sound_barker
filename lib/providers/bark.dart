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
    await Future.delayed(Duration(seconds: 3), () => print('done')); // This is temporary.
    await splitAudio();
    return this;
  }

  Future<void> splitAudio() async {
    http.Response response;
    // User ID hardcoded as 999 for now. This should be a post request in the future.
    final url = 'http://165.227.178.14/split_audio';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'uuid': fileId,
        }),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    print(response.body.toString());
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
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    print(response.body.toString());
  }
}
