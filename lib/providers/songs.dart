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
    List tempSongs = [];
    Bucket bucket = await Gcloud.accessBucket();
    String response = await RestAPI.retrieveAllSongsFromServer();
    print("retriveallsongresponse: $response");
    json.decode(response).forEach((serverSong) {
      if (serverSong["hidden"] == 1) return;
      Song song = Song();
      song.retrieveSong(serverSong, bucket);
      print("this was created: ${song.created}");
      tempSongs.add(song);
    });
    print("tempSongs: $tempSongs");
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
    String filePathBase = myAppStoragePath + '/' + fileId;
    bucket ??= await Gcloud.accessBucket();
    this.backingTrackUrl = songData["backing_track_fp"];
    this.fileId = songData["uuid"];
    this.name = songData["name"];
    this.fileUrl = songData["bucket_fp"];
    this.formulaId = songData["song_id"];
    this.created = DateTime.parse(songData["created"]);

    if (File(filePathBase + '.csv').exists() != null &&
        File(filePathBase + '.aac').exists() != null) {
      this.filePath = filePathBase + '.aac';
      this.amplitudesPath = filePathBase + '.csv';
      return this;
    }
    this.filePath = await Gcloud.downloadFromBucket(fileUrl, fileId + '.aac',
        bucket: bucket);
    this.amplitudesPath = createAmplitudeFile(filePathBase);
    // Download backing track
    if (backingTrackUrl != null) {
      String backingTrackPath = await Gcloud.downloadFromBucket(
          backingTrackUrl, filePathBase + "backing",
          bucket: bucket);
      // merge backing track and melody, delete backing track
      await FFMpeg.converter.execute(
          "-i $filePath -i $backingTrackPath -filter_complex amix=inputs=2:duration=first:dropout_transition=3 $filePath");
      File(backingTrackPath).delete();
    }
    return this;
  }
}
