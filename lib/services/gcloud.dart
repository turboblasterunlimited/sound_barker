import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../tools/app_storage_path.dart';

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

  static Future<String> downloadFromBucket(fileUrl, fileName,
      {Bucket bucket}) async {
    if (fileUrl == null) return null;
    bucket ??= await accessBucket();
    String filePath = myAppStoragePath + '/' + fileName;
    try {
      await bucket.read(fileUrl).pipe(File(filePath).openWrite());
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
    return bucketWritePath;
  }

  static Future<Map<String, String>> uploadCardAssets(
      String audioFilePath, String imageFilePath) async {
    String audioFileWritePath = "card_audios/${basename(audioFilePath)}";
    String imageFileWritePath = "decoration_images/${basename(imageFilePath)}";

    var audioInfo;
    var imageInfo;

    Bucket bucket = await accessBucket("k9karaoke_cards");
    try {
      audioInfo = await File(audioFilePath)
          .openRead()
          .pipe(bucket.write(audioFileWritePath));
    } catch (e) {
      print(e);
    }
    try {
      imageInfo = await File(imageFilePath)
          .openRead()
          .pipe(bucket.write(imageFileWritePath));
    } catch (e) {
      print(e);
    }
    print(
        "audioDownloadLink: ${audioInfo.downloadLink}, imageDownloadLink: ${imageInfo.downloadLink}");
    return {
      "audio": audioInfo.downloadLink,
      "image": imageInfo.downloadLink
    };
  }
}
