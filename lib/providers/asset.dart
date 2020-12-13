import 'dart:io';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:flutter/material.dart';

import 'package:K9_Karaoke/services/gcloud.dart';

abstract class Asset with ChangeNotifier {
  String filePath;
  String fileUrl;
  String fileId;
  Asset({this.filePath, this.fileUrl, this.fileId}) {}

  bool get hasFile {
    return filePath != null && File(filePath).existsSync();
  }

  Future<void> download() async {
    await Gcloud.downloadFromBucket(fileUrl, filePath);
  }

  String get filePathBase {
    return myAppStoragePath + '/' + fileId;
  }
}
