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

  void uploadBark() {
    rootBundle
        .loadString('credentials/gcloud_credentials.json')
        .then((credData) {
      var credentials = auth.ServiceAccountCredentials.fromJson(credData);
      List<String> scopes = []..addAll(Storage.SCOPES);

      auth
          .clientViaServiceAccount(credentials, scopes)
          .then((auth.AutoRefreshingAuthClient client) {
        var storage = Storage(client, 'songbarker');
        Bucket bucket = storage.bucket('song_barker_sequences');
        File(this.filePath)
            .openRead()
            .pipe(bucket.write("${this.uniqueFileName}.aac"));
      });
    });
  }
}
