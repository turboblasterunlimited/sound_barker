import 'package:K9_Karaoke/providers/asset.dart';
import 'package:K9_Karaoke/providers/creatable_songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/gcloud.dart';
import 'dart:io';

import '../tools/ffmpeg.dart';
import '../services/rest_api.dart';
import '../tools/amplitude_extractor.dart';

// final captureBackingFileName = RegExp(r'\/([0-9a-zA-Z_ ]*.[a-zA-Z]{3})$');

class Songs with ChangeNotifier {
  List<Song> all = [];
  // List<CreatableSong> creatableSongs;
  CreatableSongs creatableSongs;

  void removeAll() {
    all = [];
    creatableSongs.all = [];
  }

  void setCreatableSongs(CreatableSongs creatables) {
    creatableSongs = creatables;
    creatableSongs.sort();
  }

  Song findById(String id) {
    try {
      return all.firstWhere((test) => test.fileId == id);
    } catch (e) {
      return null;
    }
  }

  void addSong(song) {
    song.songFamily = getSongFamily(song.formulaId);
    all.insert(0, song);
  }

  void removeSong(songToDelete) {
    RestAPI.deleteSong(songToDelete);
    all.remove(songToDelete);
    songToDelete.deleteFiles();
    notifyListeners();
  }

  void deleteAll() {
    all.forEach((song) => song.deleteFiles());
  }

  String getSongFamily(String id) {
    int i = creatableSongs.all
        .indexWhere((CreatableSong creatable) => creatable.ids.indexOf(int.parse(id)) != -1);
    return creatableSongs.all[i].fullName;
  }

  // ALL SONGS THAT AREN'T HIDDEN UNLESS THEY ALREADY EXIST ON THE CLIENT
  Future retrieveAll() async {
    List tempSongs = [];
    List serverSongs = await RestAPI.retrieveAllSongs();
    print("retriveallsongresponse: $serverSongs");

    for (Map<String, dynamic> serverSong in serverSongs) {
      if (serverSong["hidden"] == 1) continue;
      final song = await Song().setSongData(serverSong);
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

class Song extends Asset {
  String name;
  String filePath;
  String fileId;
  String formulaId;
  String backingTrackUrl;
  DateTime created;
  String amplitudesPath;
  String songFamily; // fullName of creatableSong (name OR "$name ($style)")
  String bucketFp;
  Song(
      {this.bucketFp,
      this.filePath,
      this.name,
      this.fileId,
      this.formulaId,
      this.backingTrackUrl,
      this.created,
      this.amplitudesPath,
      this.songFamily});

  bool get exists {
    return File(filePath).existsSync();
  }

  String get getName {
    if (name == "" || name == null) return "Unnamed";
    return name;
  }

  Future<void> rename(newName) async {
    try {
      await RestAPI.renameSong(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  Future<Song> setSongData(Map songData) async {
    print("retrieving song: $songData");
    this.backingTrackUrl = songData["backing_track_fp"];
    this.fileId = songData["uuid"];
    this.name = songData["name"];
    this.bucketFp = songData["bucket_fp"];
    this.formulaId = songData["song_id"].toString();
    this.created = DateTime.parse(songData["created"]);

    _setIfFilesExist(filePathBase);

    return this;
  }

  Future<void> downloadAndCombineSong() async {
    await _getMelodyAndGenerateAmplitudeFile(filePathBase);
    if (backingTrackUrl != null) {
      String backingTrackPath = filePathBase + "backing.aac";
      await Gcloud.downloadFromBucket(backingTrackUrl, backingTrackPath);
      await _mergeTracks(backingTrackPath, filePathBase);
    }
  }

  void deleteFiles() {
    if (!hasFile) return;
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    if (File(amplitudesPath).existsSync()) File(amplitudesPath).deleteSync();
  }

  Future<void> reDownload() async {
    print("downloading $fileId");
    deleteFiles();
    await downloadAndCombineSong();
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

  Future<void> _getMelodyAndGenerateAmplitudeFile(filePathBase) async {
    this.filePath =
        await Gcloud.downloadFromBucket(bucketFp, filePathBase + '.aac');
    this.amplitudesPath = await AmplitudeExtractor.createAmplitudeFile(
        this.filePath, filePathBase);
  }

  Future<void> _mergeTracks(backingTrackPath, filePathBase) async {
    String tempMelodyFilePath = filePathBase + "temp.aac";
    print("MERGING...");
    await FFMpeg.process.execute(
        "-i $backingTrackPath -i ${this.filePath} -filter_complex amix=inputs=2:duration=longest:dropout_transition=20 -ac 1 $tempMelodyFilePath");
    File(tempMelodyFilePath).renameSync(this.filePath);
    File(backingTrackPath).deleteSync();
  }
}
