import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gcloud/storage.dart';
import '../services/gcloud.dart';
import 'dart:convert';
import 'dart:io';

import '../services/rest_api.dart';

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
  String backingTrackPath;
  DateTime created;

  Song(
      {String filePath,
      String name,
      String fileUrl,
      String fileId,
      String formulaId,
      String backingTrackUrl,
      String backingTrackPath,
      DateTime created}) {
    this.filePath = filePath;
    this.name = name;
    this.fileUrl = fileUrl;
    this.fileId = fileId;
    this.formulaId = formulaId;
    this.backingTrackUrl = backingTrackUrl;
    this.backingTrackPath = backingTrackPath;
    this.created = created;
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
    //print(data);
    bucket ??= await Gcloud.accessBucket();
    this.backingTrackUrl = songData["backing_track_fp"];
    this.fileId = songData["uuid"];
    this.name = songData["name"];
    this.fileUrl = songData["bucket_fp"];
    this.formulaId = songData["song_id"];
    this.created = DateTime.parse(songData["created"]);
    this.filePath =
        await Gcloud.downloadFromBucket(fileUrl, fileId, bucket: bucket);
    if (backingTrackUrl != null) {
      final match = captureBackingFileName.firstMatch(backingTrackUrl);
      String backingFileName = match.group(1);

      this.backingTrackPath = await Gcloud.downloadFromBucket(
          backingTrackUrl, backingFileName,
          backingTrack: true);
    }
    return this;
  }
}
