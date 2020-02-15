import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Song {
  String name;
  String fileUrl;
  final String filePath;
  final String id = Uuid().v4();

  Song({this.filePath, this.name});

 
  void playSong() {}

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

}
