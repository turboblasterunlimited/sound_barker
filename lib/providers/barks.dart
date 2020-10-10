import 'package:flutter/material.dart';
import 'package:K9_Karaoke/tools/amplitude_extractor.dart';
import 'package:K9_Karaoke/tools/app_storage_path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';
import '../tools/amplitude_extractor.dart';
import 'asset.dart';

class Barks with ChangeNotifier {
  List<Bark> all = [];
  List<Bark> stockBarks = [];
  Bark tempRawBark;
  List tempRawBarkAmplitudes;

  void removeAll() {
    all = [];
    stockBarks = [];
  }

  Future<void> setTempRawBark(rawBark) async {
    print("Raw check: ${rawBark.filePath}");
    tempRawBark = rawBark;
    tempRawBarkAmplitudes =
        await AmplitudeExtractor.getAmplitudes(tempRawBark.filePath);
    notifyListeners();
  }

  void addBark(bark) {
    all.insert(0, bark);
    notifyListeners();
  }

  void addStockBark(bark) {
    stockBarks.insert(0, bark);
    notifyListeners();
  }

  List<Bark> barksOfLength(String length,
      {bool stock = false, bool fx = false}) {
    if (fx == true) stock = true;

    List<Bark> barks = stock ? stockBarks : all;
    if (fx == true) {
      print("test: fx");
      return List.from(barks
          .where((Bark bark) => bark.length == length && bark.type != "bark"));
    } else if (stock == true) {
      print("test: stock");
      return List.from(barks.where((Bark bark) {
        return bark.length == length && bark.isStock && bark.type == "bark";
      }));
    } else {
      print("test: mybarks");
      return List.from(barks.where((Bark bark) {
        return bark.length == length && !bark.isStock;
      }));
    }
  }

  Future retrieveAll() async {
    List barks = await RestAPI.retrieveAllBarks();
    print("all barks response: $barks");
    List tempBarks = [];

    barks.forEach((serverBark) async {
      if (serverBark["hidden"] == 1) return;
      Bark bark = _serverDataToBark(serverBark);
      tempBarks.add(bark);
    });
    // await downloadAllBarksFromBucket(tempBarks);
    tempBarks.forEach((bark) {
      bark.isStock ? addStockBark(bark) : addBark(bark);
    });
    all.sort((bark1, bark2) {
      return bark1.created.compareTo(bark2.created);
    });
    stockBarks.sort((bark1, bark2) {
      return bark1.name.compareTo(bark2.name);
    });
  }

  // downloads the files either from all barks in memory or just the barks passed.
  Future downloadAllBarksFromBucket([List barks]) async {
    print("downloading all barks");
    barks ??= all;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      String filePathBase = myAppStoragePath + '/' + barks[i].fileId;

      // set filePaths in advance
      barks[i].filePath = filePathBase + '.aac';
      barks[i].amplitudesPath = filePathBase + '.csv';

      // download and generate amplitude file if none exist
      if (!File(barks[i].filePath).existsSync()) {
        await Gcloud.downloadFromBucket(barks[i].fileUrl, barks[i].filePath);
      }
      if (!File(barks[i].amplitudesPath).existsSync()) {
        await AmplitudeExtractor.createAmplitudeFile(
            barks[i].filePath, filePathBase);
      }
    }
  }

  List get allBarks {
    return all;
  }

  void remove(Bark barkToDelete) {
    if (barkToDelete.isStock)
      return print("can't delete stock bark"); // should throw error
    barkToDelete.deleteFromServer();
    all.remove(barkToDelete);
    barkToDelete.deleteFiles();
    notifyListeners();
  }

  void deleteAll() {
    all.forEach((bark) => bark.deleteFiles());
    stockBarks.forEach((bark) => bark.deleteFiles());
  }

  Future<List> uploadRawBarkAndRetrieveCroppedBarks(imageId) async {
    await Gcloud.uploadRawBark(tempRawBark.fileId, tempRawBark.filePath);
    List responseBody = await RestAPI.splitRawBark(tempRawBark.fileId, imageId);
    List newBarks = await parseCroppedBarks(responseBody);
    await downloadAllBarksFromBucket(newBarks);
    int length = newBarks.length;
    for (var i = 0; i < length; i++) {
      addBark(newBarks[i]);
    }
  }

  String _lengthAdjective(double seconds) {
    if (seconds < 0.7)
      return "short";
    else if (seconds < 1.1)
      return "medium";
    else
      return "finale";
  }

  Future<List> parseCroppedBarks(List serverBarks) async {
    List newBarks = [];
    int barkCount = serverBarks.length;
    for (var i = 0; i < barkCount; i++) {
      newBarks.add(_serverDataToBark(serverBarks[i]));
    }
    print("from parse cropped: $newBarks");
    return newBarks;
  }

  _serverDataToBark(serverBark) {
    return Bark(
      isStock: serverBark["is_stock"] == 1 ? true : false,
      type: serverBark["crop_type"],
      name: serverBark["name"],
      fileUrl: serverBark["bucket_fp"],
      fileId: serverBark["uuid"],
      created: DateTime.parse(serverBark["created"]),
      length: _lengthAdjective(serverBark["duration_seconds"]),
    );
  }
}

class Bark extends Asset {
  String name;
  String fileUrl;
  // filePath is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  String filePath;
  String fileId;
  DateTime created;
  String amplitudesPath;
  String length;
  bool isStock;
  String type;

  Bark({
    this.name,
    this.filePath,
    this.fileUrl,
    this.fileId,
    this.created,
    this.amplitudesPath,
    this.length,
    this.isStock,
    this.type,
  }) {
    this.fileId = fileId ??= Uuid().v4();
    this.created = created ??= DateTime.now();
    this.isStock = isStock ??= false;
    inferFilePath();
  }

  void inferFilePath() {
    // if its a raw bark, filePath will be set to rawBark.aac
    if (filePath != null) return;
    String fileName = fileId + '.aac';
    this.filePath = myAppStoragePath + '/' + fileName;
  }

  String get getName {
    if (name == "" || name == null) return "Unnamed";
    return name;
  }

  void deleteFiles() {
    try {
      File(filePath).deleteSync();
      File(amplitudesPath).deleteSync();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> retrieve() async {
    await download();
    this.amplitudesPath =
        await AmplitudeExtractor.createAmplitudeFile(filePath, filePathBase);
  }

  Future<void> rename(newName) async {
    try {
      await RestAPI.renameBark(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  void deleteFromServer() {
    RestAPI.deleteBark(this);
  }
}
