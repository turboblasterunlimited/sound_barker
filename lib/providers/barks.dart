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
  Bark? tempRawBark;
  List? tempRawBarkAmplitudes;

  void removeAll() {
    all = [];
    stockBarks = [];
  }

  Future<void> setTempRawBark(rawBark) async {
    print("Raw check: ${rawBark.filePath}");
    tempRawBark = rawBark;
    tempRawBarkAmplitudes =
        await AmplitudeExtractor.getAmplitudes(tempRawBark!.filePath);
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
    barks.sort(); // added JMF - 27 April 2022
    if (fx == true) {
      print("test: fx");
      List<Bark> sfx = List.from(barks
          .where((Bark bark) => bark.length == length && bark.type != "bark"));
      if (length == "medium") {
        sfx += List.from(barks.where(
            (Bark bark) => bark.length == "short" && bark.type != "bark"));
      } else if (length == "finale") {
        sfx += List.from(barks.where(
            (Bark bark) => bark.length == "medium" && bark.type != "bark"));
        sfx += List.from(barks.where(
            (Bark bark) => bark.length == "short" && bark.type != "bark"));
      }
      return sfx;
      // return List.from(barks
      //     .where((Bark bark) => bark.length == length && bark.type != "bark"));
    } else if (stock == true) {
      print("test: stock");
      return List.from(barks.where((Bark bark) {
        return bark.length == length && bark.isStock! && bark.type == "bark";
      }));
    } else {
      print("test: mybarks");
      return List.from(barks.where((Bark bark) {
        return bark.length == length && !bark.isStock!;
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
      return bark1.created!.compareTo(bark2.created!);
    });
    stockBarks.sort((bark1, bark2) {
      return bark1.name!.compareTo(bark2.name!);
    });
  }

  // downloads the files either from all barks in memory or just the barks passed.
  Future downloadAllBarksFromBucket([List? barks]) async {
    print("downloading all barks");
    barks ??= all;
    int barkCount = barks.length;
    for (var i = 0; i < barkCount; i++) {
      String filePathBase = myAppStoragePath! + '/' + barks[i].fileId;

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
    if (barkToDelete.isStock!)
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

  void deleteTempRawBark() {
    if (tempRawBark == null) return;
    if (File(tempRawBark!.filePath!).existsSync())
      File(tempRawBark!.filePath!).deleteSync();
    tempRawBark = null;
    tempRawBarkAmplitudes = null;
  }

  Future<void> uploadRawBarkAndRetrieveCroppedBarks(imageId) async {
    try {
      print("Raw barks: " + tempRawBark!.filePath.toString());
      await Gcloud.uploadRawBark(tempRawBark!.fileId, tempRawBark!.filePath);
      List responseBody =
          await RestAPI.splitRawBark(tempRawBark!.fileId, imageId);
      List newBarks = await parseCroppedBarks(responseBody);
      await downloadAllBarksFromBucket(newBarks);
      int length = newBarks.length;
      for (var i = 0; i < length; i++) {
        addBark(newBarks[i]);
      }
      deleteTempRawBark();
    } catch (e) {
      print(e.toString());
    }
  }

  String _lengthAdjective(double seconds) {
    print("Seconds: $seconds");
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
      length: _lengthAdjective(serverBark["duration_seconds"].toDouble()),
    );
  }
}

class Bark extends Asset implements Comparable {
  String? name;
  String? fileUrl;
  // filePath is initially used for file upload from temp directory. Later (for cropped barks) it can be used for playback.
  String? filePath;
  String? fileId;
  DateTime? created;
  String? amplitudesPath;
  String? length;
  bool? isStock;
  String? type;

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
    this.filePath = "$myAppStoragePath/$fileId.aac";
    this.amplitudesPath = "$myAppStoragePath/$fileId.csv";
  }

  String get getName {
    if (name == "" || name == null) return "Unnamed";
    return name!;
  }

  void deleteFiles() {
    if (File(filePath!).existsSync()) File(filePath!).deleteSync();
    if (File(amplitudesPath!).existsSync()) File(amplitudesPath!).deleteSync();
  }

  Future<void> reDownload() async {
    print("downloading $fileId");
    deleteFiles();
    await retrieve();
  }

  Future<void> retrieve() async {
    await download();
    if (!File(amplitudesPath!).existsSync()) {
      await AmplitudeExtractor.createAmplitudeFile(filePath, filePathBase);
    }
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

// Added - jmf 27 April 2022
  int dogSizeCode() {
    if (name!.startsWith("Puppy")) {
      return 0;
    } else if (name!.startsWith("Small")) {
      return 1;
    } else if (name!.startsWith("Medium") || name!.startsWith("Dog")) {
      return 2;
    } else {
      return 3;
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  int compareNames(other) {
    if (name == null) {
      return 1; // null is bigger than anything so is last
    }
    var me = name!.split(" ");
    var meLast = me[me.length - 1];

    var them = other.name.split(" ");
    var themLast = them[them.length - 1];

    var mePrefix = "";
    var themPrefix = "";
    for (int i = 0; i < me.length - 1; i++) {
      mePrefix += me[i];
    }
    for (int i = 0; i < them.length - 1; i++) {
      themPrefix += them[i];
    }

    if (mePrefix != themPrefix) {
      return name!.compareTo(other.name);
    }

    // compare number suffix if names are same except for numeric suffix.
    if (me.length >= 2 &&
        isNumeric(meLast) &&
        them.length >= 2 &&
        isNumeric(themLast)) {
      if (mePrefix == themPrefix) {
        var meIndex = double.tryParse(meLast);
        var themIndex = double.tryParse(themLast);
        if (meIndex == null && themIndex == null) {
          return name!.compareTo(other.name);
        } else if (themIndex == null) {
          return -1;
        } else if (meIndex! < themIndex) {
          return -1;
        } else if (meIndex > themIndex) {
          return 1;
        } else {
          return 0;
        }
      }
    } // end compare strings with numeric suffixes
    else {
      return name!.compareTo(other.name);
    }

    return 0;
  }

  @override
  int compareTo(other) {
    num sign = dogSizeCode() - other.dogSizeCode();
    if (sign < 0) {
      return -1;
    } else if (sign > 0) {
      return 1;
    } else {
//      return name!.compareTo(other.name);
      return compareNames(other);
    }
  }
  // End Added -- jmf
}
