import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gcloud/storage.dart';
import '../services/gcloud.dart';
import 'dart:io';

import '../tools/ffmpeg.dart';
import '../tools/app_storage_path.dart';
import '../services/rest_api.dart';
import '../tools/amplitude_extractor.dart';

final captureBackingFileName = RegExp(r'\/([0-9a-zA-Z_ ]*.[a-zA-Z]{3})$');

class Songs with ChangeNotifier {
  List<Song> all = [];
  final listKey = GlobalKey<AnimatedListState>();
  List creatableSongs;


  Song findById(String id) {
    return all.firstWhere((test) {
      return test.fileId == id;
    });
  }

  void addSong(song) {
    song.songFamily = getSongFamily(song.formulaId);
    all.insert(0, song);
    if (listKey.currentState != null) listKey.currentState.insertItem(0);
    notifyListeners();
  }

  void removeSong(songToDelete) {
    RestAPI.deleteSongFromServer(songToDelete);
    all.remove(songToDelete);
    File(songToDelete.filePath).delete();
  }

  String getSongFamily(String id) {
    int i = creatableSongs.indexWhere((element) => element["id"].toString() == id);
    Map result = creatableSongs[i];
    return result['song_family'];
  }

  // ALL SONGS THAT AREN'T HIDDEN UNLESS THEY ALREADY EXIST ON THE CLIENT
  Future retrieveAll() async {
    List tempSongs = [];
    Bucket bucket = await Gcloud.accessBucket();
    List serverSongs = await RestAPI.retrieveAllSongsFromServer();
    print("retriveallsongresponse: $serverSongs");

    for (Map<String, dynamic> serverSong in serverSongs) {
      if (serverSong["hidden"] == 1) continue;
      final song = await Song().retrieveSong(serverSong, bucket);
      tempSongs.add(song);
      print("song created: ${song.created}");
    }

    tempSongs.sort((song1, song2) {
      return song1.created.compareTo(song2.created);
    });
    tempSongs.forEach((song) {
      addSong(song);
    });
  }
}

class Song with ChangeNotifier {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String formulaId;
  String backingTrackUrl;
  DateTime created;
  String amplitudesPath;
  String songFamily;
  Song(
      {String filePath,
      String name,
      String fileUrl,
      String fileId,
      String formulaId,
      String backingTrackUrl,
      DateTime created,
      String amplitudesPath,
      String songFamily}) {
    this.filePath = filePath;
    this.name = name;
    this.fileUrl = fileUrl;
    this.fileId = fileId;
    this.formulaId = formulaId;
    this.backingTrackUrl = backingTrackUrl;
    this.created = created;
    this.amplitudesPath = amplitudesPath;
    songFamily = songFamily;
  }

  String get getName {
    if (name == "" || name == null) return "Unnamed";
    return name;
  }

  void removeFromStorage() {
    try {
      File(filePath).deleteSync(recursive: false);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> rename(newName) async {
    try {
      await RestAPI.renameSongOnServer(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  Future<Song> retrieveSong(Map songData, [bucket]) async {
    print("retrieving song: $songData");
    bucket ??= await Gcloud.accessBucket();
    this.backingTrackUrl = songData["backing_track_fp"];
    this.fileId = songData["uuid"];
    this.name = songData["name"];
    this.fileUrl = songData["bucket_fp"];
    this.formulaId = songData["song_id"];
    this.created = DateTime.parse(songData["created"]);
    String filePathBase = myAppStoragePath + '/' + fileId;

    if (_setIfFilesExist(filePathBase)) return this;

    await _getMelodyAndGenerateAmplitudeFile(bucket, filePathBase);
    if (backingTrackUrl != null) {
      String backingTrackPath = await Gcloud.downloadFromBucket(
          backingTrackUrl, fileId + "backing.aac",
          bucket: bucket);
      await _mergeTracks(backingTrackPath, filePathBase);
    }
    return this;
  }

  bool _setIfFilesExist(filePathBase) {
    if (File(filePathBase + '.csv').existsSync() &&
        File(filePathBase + '.aac').existsSync()) {
      this.filePath = filePathBase + '.aac';
      this.amplitudesPath = filePathBase + '.csv';
      return true;
    }
    return false;
  }

  Future<void> _getMelodyAndGenerateAmplitudeFile(bucket, filePathBase) async {
    this.filePath = await Gcloud.downloadFromBucket(fileUrl, fileId + '.aac',
        bucket: bucket);
    this.amplitudesPath = await AmplitudeExtractor.createAmplitudeFile(
        this.filePath, filePathBase);
  }

  Future<void> _mergeTracks(backingTrackPath, filePathBase) async {
    String tempMelodyFilePath = filePathBase + "temp.aac";
    print("MERGING...");
    await FFMpeg.process.execute(
        "-i $backingTrackPath -i ${this.filePath} -filter_complex amix=inputs=2:duration=longest $tempMelodyFilePath");
    File(tempMelodyFilePath).renameSync(this.filePath);
    File(backingTrackPath).deleteSync();
  }
}
