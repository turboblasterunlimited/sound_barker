import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

class Songs with ChangeNotifier {
  List<Song> all = [];
  final listKey = GlobalKey<AnimatedListState>();

  Song findById(String id) {
    return all.firstWhere((test) {
      return test.fileId == id;
    });
  }

  void addSong(song) {
    all.insert(0, song);
    if (listKey.currentState != null) listKey.currentState.insertItem(0);
  }

  void removeSong(songToDelete) {
    RestAPI.deleteSongFromServer(songToDelete);
    all.remove(songToDelete);
    File(songToDelete.filePath).delete();
  }

  // ALL SONGS THAT AREN'T HIDDEN UNLESS THEY ALREADY EXIST ON THE CLIENT
  Future retrieveAll() async {
    print("retrieve all songs check point");
    List tempSongs = [];
    Bucket bucket = await Gcloud.accessBucket();
    String response = await RestAPI.retrieveAllSongsFromServer();
    print("retriveallsongresponse: $response");
    List<dynamic> serverSongs = await json.decode(response);

    for (Map<String, dynamic> serverSong in serverSongs) {
      if (serverSong["hidden"] == 1) continue;
      final song = await Song().retrieveSong(serverSong, bucket);
      tempSongs.add(song);
      print("song created: ${song.created}");
    }

    print("tempSongs finished: $tempSongs");
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

  Song(
      {String filePath,
      String name,
      String fileUrl,
      String fileId,
      String formulaId,
      String backingTrackUrl,
      DateTime created,
      String amplitudesPath}) {
    this.filePath = filePath;
    this.name = name;
    this.fileUrl = fileUrl;
    this.fileId = fileId;
    this.formulaId = formulaId;
    this.backingTrackUrl = backingTrackUrl;
    this.created = created;
    this.amplitudesPath = amplitudesPath;
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

    _getMelodyAndGenerateAmplitudeFile(bucket, filePathBase);
    if (backingTrackUrl != null) {
      String backingTrackPath = await Gcloud.downloadFromBucket(
          backingTrackUrl, fileId + "backing.aac",
          bucket: bucket);
      _mergeTracks(backingTrackPath, filePathBase);
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

  void _getMelodyAndGenerateAmplitudeFile(bucket, filePathBase) async {
    this.filePath = await Gcloud.downloadFromBucket(fileUrl, fileId + '.aac',
        bucket: bucket);
    this.amplitudesPath = await createAmplitudeFile(filePathBase);
  }

  void _mergeTracks(backingTrackPath, filePathBase) async {
    String tempMelodyFilePath = filePathBase + "temp.aac";
    await FFMpeg.converter.execute(
        "-i $backingTrackPath -i ${this.filePath} -filter_complex amix=inputs=2:duration=longest $tempMelodyFilePath");
    File(tempMelodyFilePath).renameSync(this.filePath);
    File(backingTrackUrl).deleteSync();
  }
}
