import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';

class Bark {
  String fileUrl;
  final String filePath;
  final String uniqueFileName = Uuid().v4();

  Bark(this.filePath);

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

  void uploadBark() async {
    Bucket bucket = await accessBucket();
    File(this.filePath)
        .openRead()
        .pipe(bucket.write("${this.uniqueFileName}.aac"));
  }
}
