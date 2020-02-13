import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Bark with ChangeNotifier {
  String _name;
  String fileUrl;
  final String filePath;
  final String fileId = Uuid().v4();

  Bark(this.filePath, this._name);

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
    info = await File(filePath)
        .openRead()
        .pipe(bucket.write("$fileId/raw.aac"));
    } catch(error) {
      print('failed to put bark in the bucket');
      return error;
    }
    print(info.downloadLink);
    await notifyServer();
    return this;
  }

    Future<void> notifyServer() async {
    http.Response response;
    // User ID hardcoded as 999 for now. This should be a post request in the future.
    final url = 'http://165.227.178.14/add_audio/999/$fileId';
    try {
      response = await http.post(
        url,
        body: json.encode({
          'name': _name,
          'fileId': fileId,
          // 'isFavorite': product.isFavorite,
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
