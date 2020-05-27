import 'package:flutter/material.dart';
import 'package:gcloud/storage.dart';
import 'package:song_barker/tools/amplitude_extractor.dart';
import 'package:song_barker/tools/app_storage_path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Barks with ChangeNotifier {
  List<Bark> all = [];
  final listKey = GlobalKey<AnimatedListState>();

  void addBark(bark) {
    all.insert(0, bark);
    if (listKey.currentState != null) listKey.currentState.insertItem(0);
  }

  Future retrieveAll() async {
    List barks = await RestAPI.retrieveAllBarksFromServer();
    print("all barks response: $barks");
    List tempBarks = [];

    barks.forEach((serverBark) async {
      if (serverBark["hidden"] == 1) return;
      Bark bark = Bark(
        name: serverBark["name"],
        fileUrl: serverBark["bucket_fp"],
        fileId: serverBark["uuid"],
        created: DateTime.parse(serverBark["created"]),
      );
      tempBarks.add(bark);
    });
    downloadAllBarksFromBucket(tempBarks);
    tempBarks.sort((bark1, bark2) {
      return bark1.created.compareTo(bark2.created);
    });
    tempBarks.forEach((bark) {
      addBark(bark);
    });
  }

  // Future<String> createAmplitudeFile(filePath, filePathBase) async {
  //   await FFMpeg.converter
  //       .execute("-hide_banner -loglevel panic -i $filePathBase.aac $filePathBase.wav");
  //   final amplitudes = AmplitudeExtractor.extract("$filePathBase.wav");
  //   File("$filePathBase.wav").delete();
  //   final csvAmplitudes = const ListToCsvConverter().convert([amplitudes]);
  //   File file = File("$filePathBase.csv");
  //   file.writeAsStringSync(csvAmplitudes);
  //   return file.path;
  // }

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
        await Gcloud.downloadFromBucket(barks[i].fileUrl, barks[i].fileId + '.aac',
            bucket: bucket);
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

  void remove(barkToDelete) {
    barkToDelete.deleteFromServer();
    all.remove(barkToDelete);
    File(barkToDelete.filePath).delete();
    notifyListeners();
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

  Bark({
    String name,
    String filePath,
    String fileUrl,
    String fileId,
    DateTime created,
    String amplitudesPath,
  }) {
    this.name = name;
    this.filePath = filePath;
    this.fileUrl = fileUrl;
    this.fileId = fileId ??= Uuid().v4();
    this.created = created ??= DateTime.now();
    this.amplitudesPath = amplitudesPath;
  }

  String get getName {
    if (name == "") return "Unnamed";
    return name;
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

  Future<List> uploadBarkAndRetrieveCroppedBarks(imageId) async {
    await Gcloud.uploadAsset(fileId, filePath, false);
    List responseBody = await RestAPI.splitRawBarkOnServer(fileId, imageId);
    List newBarks = parseCroppedBarks(responseBody);
    return newBarks;
  }

  List parseCroppedBarks(List cloudBarkData) {
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
