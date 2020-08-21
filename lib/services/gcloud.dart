import 'dart:io';
import 'package:K9_Karaoke/classes/card_audio.dart';
import 'package:K9_Karaoke/classes/card_decoration_image.dart';
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
    Bucket bucket = await accessBucket();
    try {
      await File(filePath).openRead().pipe(bucket.write(bucketWritePath));
    } catch (e) {
      print(e);
      return e;
    }
    return bucketWritePath;
  }

  static Future<String> uploadDecorationImage(
      CardDecorationImage decorationImage,
      [Bucket bucket]) async {
    final decorationImageWritePath =
        "decoration_images/${basename(decorationImage.filePath)}";
    bucket ??= await accessBucket();
    try {
      await File(decorationImage.filePath)
          .openRead()
          .pipe(bucket.write(decorationImageWritePath));
    } catch (e) {
      print(e);
    }

    return decorationImageWritePath;
  }

  static Future<String> uploadCardAudio(CardAudio cardAudio,
      [Bucket bucket]) async {
    final audioFileWritePath = "card_audios/${basename(cardAudio.filePath)}";
    bucket ??= await accessBucket();
    try {
      await File(cardAudio.filePath)
          .openRead()
          .pipe(bucket.write(audioFileWritePath));
    } catch (e) {
      print(e);
    }

    return audioFileWritePath;
  }
}
