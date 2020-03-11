import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../functions/app_storage_path.dart';

class Gcloud {
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

  Future<String> downloadFromBucket(fileUrl, fileId, [image]) async {
    String filePath = myAppStoragePath + '/' + fileId;
    filePath += image == true ? ".jpg" : '.aac';
    Bucket bucket = await accessBucket();
    // print(image ? "THIS Is an IMAGE!!!" : "");
    // print("fileUrl: $fileUrl, filePath: $filePath");
    try { bucket.read(fileUrl).pipe(new File(filePath).openWrite());
    } catch (e) {
      print(e);
    }
    return filePath;
  }

  Future<String> uploadAsset(fileId, filePath, [image]) async {
    String bucketWritePath = image == true ? "images/$fileId.jpg" : "$fileId/raw.aac";
    var info;
    Bucket bucket = await accessBucket();
    try {
      info =
          await File(filePath).openRead().pipe(bucket.write(bucketWritePath));
    } catch (error) {
      print(error);
      return error;
    }
    return info.downloadLink.toString();
  }
}
