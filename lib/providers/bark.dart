import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:flutter/foundation.dart';

class Bark with ChangeNotifier {
  String _title;
  String fileUrl;
  final String filePath;
  final String uniqueFileName = Uuid().v4();

  Bark(this.filePath, this._title);

  String get title {
    return _title;
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
    ObjectInfo info = await File(this.filePath)
        .openRead()
        .pipe(bucket.write("${this.uniqueFileName}.aac"));
    } catch(error) {
      print('failed to put bark in the bucket');
      return error;
    }
    print(info.downloadLink);
    return this;
  }
}
