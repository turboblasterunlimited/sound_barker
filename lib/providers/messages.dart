import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gcloud/pubsub.dart';
import 'package:gcloud/storage.dart';
import '../services/gcloud.dart';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import '../services/ffmpeg.dart';
import '../functions/app_storage_path.dart';
import '../services/rest_api.dart';
import '../services/amplitude_extractor.dart';

final captureBackingFileName = RegExp(r'\/([0-9a-zA-Z_ ]*.[a-zA-Z]{3})$');

class Messages with ChangeNotifier {
  List<Message> all = [];

  Message findById(String id) {
    return all.firstWhere((test) {
      return test.fileId == id;
    });
  }

  void addMessage(message) {
    all.insert(0, message);
  }

  void removeMessage(message) {
    RestAPI.deleteSongFromServer(message);
    all.remove(message);
    File(message.filePath).delete();
  }

}
class Message with ChangeNotifier {
  String filePath;
  String fileId;
  String amplitudesPath;

  Message(
      {String filePath,
      String name,
      String fileId,
      String amplitudesPath}) {
    this.filePath = filePath;
    this.fileId = fileId;
    this.amplitudesPath = amplitudesPath;
  }

  void removeFromStorage() {
    try {
      File(filePath).deleteSync(recursive: false);
    } catch (e) {
      print("Error: $e");
    }
  }

  createAmplitudeFile(filePathBase) async {
    await FFMpeg.converter
        .execute("-hide_banner -loglevel panic -i $filePath $filePathBase.wav");
    final amplitudes = AmplitudeExtractor.extract("$filePathBase.wav");
    File("$filePathBase.wav").delete();
    final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
    File file = File("$filePathBase.csv");
    file.writeAsStringSync(csvAmplitudes);
    return file.path;
  }

}
