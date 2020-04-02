import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../functions/app_storage_path.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class Gcloud {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

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

  Future<String> downloadFromBucket(fileUrl, fileId, {image, bucket}) async {
    bucket ??= await accessBucket();
    String filePathBase = myAppStoragePath + '/' + fileId;
    String filePath = filePathBase;
        
    if (image == true) {
      filePath += ".jpg";
      if (await File(filePath).exists()) return filePath;
    } else {
      filePath += ".aac";
      if (await File(filePathBase + ".wav").exists()) return filePathBase + ".wav";
    }
    try { 
      await bucket.read(fileUrl).pipe(new File(filePath).openWrite());
      if (image != true) {
        // Makes a wav file and deletes the .aac file.
        await _flutterFFmpeg.execute("-i $filePath $filePathBase.wav");
        File(filePath).delete();
        filePath = filePathBase + ".wav";
      }
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
