import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class Gcloud {
  static Future<Bucket> accessBucket(
      [bucket_name = "song_barker_sequences"]) async {
    var credData =
        await rootBundle.loadString('credentials/gcloud_credentials.json');
    var credentials = auth.ServiceAccountCredentials.fromJson(credData);
    List<String> scopes = []..addAll(Storage.SCOPES);
    auth.AutoRefreshingAuthClient client =
        await auth.clientViaServiceAccount(credentials, scopes);
    var storage = Storage(client, 'songbarker');
    return storage.bucket(bucket_name);
  }

  static Future<String> downloadFromBucket(String bucketFp, String filePath,
      {Bucket bucket}) async {
    // if (bucketFp == null) return null;
    bucket ??= await accessBucket();
    try {
      await bucket.read(bucketFp).pipe(File(filePath).openWrite());
    } catch (e) {
      print(e);
    }
    return filePath;
  }

  static Future<String> uploadRawBark(fileId, filePath) async {
    String bucketWritePath = "$fileId/raw.aac";
    Bucket bucket = await accessBucket();
    try {
      await File(filePath).openRead().pipe(bucket.write(bucketWritePath));
    } catch (e) {
      print(e);
      return e;
    }
    return bucketWritePath;
  }

  static Future<String> upload(String filePath, String directory,
      [Bucket bucket]) async {
    final bucketFp = "$directory/${basename(filePath)}";
    bucket ??= await accessBucket();
    try {
      await File(filePath).openRead().pipe(bucket.write(bucketFp));
    } catch (e) {
      print(e);
    }
    return bucketFp;
  }
}
