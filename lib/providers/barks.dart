import 'package:K9_Karaoke/tools/ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';
import '../tools/amplitude_extractor.dart';

class Barks with ChangeNotifier {
  List<Bark> all = [];
  List<Bark> stockBarks = [];
  final listKey = GlobalKey<AnimatedListState>();
  final listKeyStock = GlobalKey<AnimatedListState>();
  Bark tempRawBark;
  List tempRawBarkAmplitudes;

  Future<void> setTempRawBark(rawBark) async {
    tempRawBark = rawBark;
    tempRawBarkAmplitudes =
        await AmplitudeExtractor.getAmplitudes(tempRawBark.filePath);
    notifyListeners();
  }

  void addBark(bark) {
    all.insert(0, bark);
    if (listKey.currentState != null) listKey.currentState.insertItem(0);
    notifyListeners();
  }

  void addStockBark(bark) {
    stockBarks.insert(0, bark);
    if (listKeyStock.currentState != null)
      listKeyStock.currentState.insertItem(0);
    notifyListeners();
  }

  List<Bark> barksOfLength(String length, [bool stock = false]) {
    List<Bark> barks = stock ? stockBarks : all;
    return List.from(barks.where((bark) => bark.length == length));
  }

  List<Bark> short([bool isStock = false]) {
    return barksOfLength("short", isStock);
  }

  List<Bark> medium([bool isStock = false]) {
    return barksOfLength("medium", isStock);
  }

  List<Bark> long([bool isStock = false]) {
    return barksOfLength("long", isStock);
  }

  Future retrieveAll() async {
    List barks = await RestAPI.retrieveAllBarksFromServer();
    print("all barks response: $barks");
    List tempBarks = [];

    barks.forEach((serverBark) async {
      if (serverBark["hidden"] == 1) return;
      Bark bark = Bark(
        isStock: serverBark["is_stock"] == 1 ? true : false,
        name: serverBark["name"],
        fileUrl: serverBark["bucket_fp"],
        fileId: serverBark["uuid"],
        created: DateTime.parse(serverBark["created"]),
      );
      tempBarks.add(bark);
    });
    await downloadAllBarksFromBucket(tempBarks);
    tempBarks.sort((bark1, bark2) {
      return bark1.created.compareTo(bark2.created);
    });
    tempBarks.forEach((bark) {
      bark.isStock ? addStockBark(bark) : addBark(bark);
    });
  }

  Future<void> _setLengthProp(Bark bark) async {
    String tempPath = myAppStoragePath + "/temp_file.wav";
    await FFMpeg.process.execute('-i ${bark.filePath} $tempPath');
    Map info = await FFMpeg.probe.getMediaInformation(tempPath);
    var duration = info["duration"].toString();
    bark.setLengthProp(int.parse(duration));
    File(tempPath).deleteSync();
  }

  // downloads the files either from all barks in memory or just the barks passed.
  Future downloadAllBarksFromBucket([List barks]) async {
    print("downloading all barks");
    Bucket bucket = await Gcloud.accessBucket();
    barks ??= all;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      String filePathBase = myAppStoragePath + '/' + barks[i].fileId;

      // set filePaths in advance
      barks[i].filePath = filePathBase + '.aac';
      barks[i].amplitudesPath = filePathBase + '.csv';

      // download and generate amplitude file if none exist
      if (!File(barks[i].filePath).existsSync()) {
        await Gcloud.downloadFromBucket(
            barks[i].fileUrl, barks[i].fileId + '.aac',
            bucket: bucket);
      }
      if (!File(barks[i].amplitudesPath).existsSync()) {
        await AmplitudeExtractor.createAmplitudeFile(
            barks[i].filePath, filePathBase);
      }
      await _setLengthProp(barks[i]);
    }
  }

  List get allBarks {
    return all;
  }

  void remove(barkToDelete) {
    if (barkToDelete.isStock)
      return print("can't delete stock bark"); // should throw error
    barkToDelete.deleteFromServer();
    all.remove(barkToDelete);
    File(barkToDelete.filePath).delete();
    notifyListeners();
  }

  Future<List> uploadRawBarkAndRetrieveCroppedBarks(imageId) async {
    await Gcloud.uploadAsset(tempRawBark.fileId, tempRawBark.filePath, false);
    List responseBody =
        await RestAPI.splitRawBarkOnServer(tempRawBark.fileId, imageId);
    List newBarks = await parseCroppedBarks(responseBody);
    await downloadAllBarksFromBucket(newBarks);
    int length = newBarks.length;
    for (var i = 0; i < length; i++) {
      addBark(newBarks[i]);
    }
  }

  Future<List> parseCroppedBarks(List cloudBarkData) async {
    List newBarks = [];
    int barkCount = cloudBarkData.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(Bark(
        fileId: cloudBarkData[i]["uuid"],
        name: cloudBarkData[i]["name"],
        fileUrl: cloudBarkData[i]["bucket_fp"],
        created: DateTime.parse(cloudBarkData[i]["created"]),
      ));
    }
    return newBarks;
  }
}

class Bark with ChangeNotifier {
  String name;
  String fileUrl;
  // filePath is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  String filePath;
  String fileId;
  DateTime created;
  String amplitudesPath;
  String length;
  bool isStock;

  Bark({
    String name,
    String filePath,
    String fileUrl,
    String fileId,
    DateTime created,
    String amplitudesPath,
    String length,
    bool isStock,
  }) {
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.created = created ??= DateTime.now();
    this.amplitudesPath = amplitudesPath;
    this.length = length;
    this.isStock = isStock ??= false;
  }

  String get getName {
    if (name == "" || name == null) return "Unnamed";
    return name;
  }

  void setLengthProp(int milliseconds) {
    if (milliseconds < 600)
      this.length = "short";
    else if (milliseconds < 900)
      this.length = "medium";
    else
      this.length = "long";
    print("Bark length: $length");
    notifyListeners();
  }

  Future<void> rename(newName) async {
    try {
      await RestAPI.renameBarkOnServer(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  void deleteFromServer() {
    RestAPI.deleteBarkFromServer(this);
  }
}
