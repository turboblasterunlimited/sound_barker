import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../functions/app_storage_path.dart';

class Gcloud {
  static Future<Bucket> accessBucket() async {
    var credData =
        await rootBundle.loadString('credentials/gcloud_credentials.json');
    var credentials = auth.ServiceAccountCredentials.fromJson(credData);
    List<String> scopes = []..addAll(Storage.SCOPES);
    auth.AutoRefreshingAuthClient client =
        await auth.clientViaServiceAccount(credentials, scopes);
    var storage = Storage(client, 'songbarker');
    return storage.bucket('song_barker_sequences');
  }

  static Future<String> downloadFromBucket(fileUrl, fileName,
      {Bucket bucket}) async {
    bucket ??= await accessBucket();
    String filePath = myAppStoragePath + '/' + fileName;
    try {
      print("downloading: $filePath");
      await bucket.read(fileUrl).pipe(new File(filePath).openWrite());
    } catch (e) {
      print(e);
    }
    return filePath;
  }

  static Future<String> uploadAsset(fileId, filePath, [image]) async {
    String bucketWritePath =
        image == true ? "images/$fileId.jpg" : "$fileId/raw.aac";
    var info;
    Bucket bucket = await accessBucket();
    try {
      info =
          await File(filePath).openRead().pipe(bucket.write(bucketWritePath));
    } catch (e) {
      print(e);
      return e;
    }
    return info.downloadLink.toString();
  }
}
