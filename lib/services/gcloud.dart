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

  Future<String> downloadSoundFromBucket(fileUrl, fileId) async {
    String path = await appStoragePath();
    String filePath = path + '/' + fileId + '.aac';
    if (await File(filePath).exists()) return filePath;
    print("FILE PATH DOES NOT EXIST! $filePath");
    Bucket bucket = await accessBucket();
    bucket.read(fileUrl).pipe(new File(filePath).openWrite());
    return filePath;
  }

  Future<String> uploadPicture(fileId, filePath) async {
    var info;
    Bucket bucket = await accessBucket();
    try {
      info =
          await File(filePath).openRead().pipe(bucket.write("images/$fileId.jpg"));
    } catch (error) {
      //print('failed to put bark in the bucket');
      return error;
    }
    return info.downloadLink.toString();
  }

  Future<String> uploadRawBark(fileId, filePath) async {
    var info;
    Bucket bucket = await accessBucket();
    try {
      info =
          await File(filePath).openRead().pipe(bucket.write("$fileId/raw.aac"));
    } catch (error) {
      //print('failed to put bark in the bucket');
      return error;
    }
    return info.downloadLink.toString();
  }
}