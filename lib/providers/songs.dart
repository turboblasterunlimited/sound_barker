import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gcloud/storage.dart';
import '../services/gcloud.dart';
import 'dart:convert';
import 'dart:io';

import '../services/rest_api.dart';

class Songs with ChangeNotifier, Gcloud, RestAPI {
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
    // notifyListeners();
  }

  void removeSong(songToDelete) {
    songToDelete.deleteFromServer();
    all.remove(songToDelete);
    File(songToDelete.filePath).delete();
    // notifyListeners();
  }

  // ALL SONGS THAT AREN'T HIDDEN UNLESS THEY EXIST
  Future retrieveAll() async {
    String response = await retrieveAllSongsFromServer();
    json.decode(response).forEach((serverSong) {
      if (serverSong["hidden"] == 1) return;
      Song song = Song(
          backingTrackUrl: serverSong["backing_track_fp"],
          formulaId: serverSong["song_id"],
          name: serverSong["name"],
          fileUrl: serverSong["bucket_fp"],
          fileId: serverSong["uuid"]);
      if (all.indexWhere((song) => song.fileId == serverSong["uuid"]) == -1) {
        _downloadAllSongsFromBucket([song]);
        addSong(song);
      }
    });

    // notifyListeners();
  }

  // downloadFromBucket only downloads songs that don't already exist on the FS
  Future _downloadAllSongsFromBucket([List songs]) async {
    final captureBackingFileName = RegExp(r'\/([0-9a-zA-Z_ ]*.[a-zA-Z]{3})$');

    Bucket bucket = await accessBucket();
    songs ??= all;
    int soundCount = songs.length;
    for (var i = 0; i < soundCount; i++) {
      String filePath = await downloadFromBucket(
          songs[i].fileUrl, songs[i].fileId,
          bucket: bucket);
      songs[i].filePath = filePath;

      if (songs[i].backingTrackUrl != null) {
        final match =
            captureBackingFileName.firstMatch(songs[i].backingTrackUrl);
        String backingFileName = match.group(1);
        songs[i].backingTrackPath = await downloadFromBucket(
            songs[i].backingTrackUrl, backingFileName,
            backingTrack: true, bucket: bucket);
      }
    }
  }
}

class Song with ChangeNotifier, Gcloud, RestAPI {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String formulaId;
  String backingTrackUrl;
  String backingTrackPath;

  Song(
      {this.filePath,
      this.name,
      this.fileUrl,
      this.fileId,
      this.formulaId,
      this.backingTrackUrl,
      this.backingTrackPath});

  void removeFromStorage() {
    try {
      File(filePath).deleteSync(recursive: false);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String> deleteFromServer() {
    return deleteSongFromServer(this);
  }

  Future<void> rename(newName) async {
    try {
      await renameSongOnServer(this, newName);
    } catch (e) {
      throw e;
    }
    this.name = newName;
    notifyListeners();
  }

  void retrieveSong(responseBody) async {
    //print(responseBody);
    Map responseData = json.decode(responseBody);
    this.backingTrackUrl = responseData["backing_track_fp"];
    this.fileId = responseData["uuid"];
    this.name = responseData["name"];
    this.fileUrl = responseData["bucket_fp"];
    this.formulaId = responseData["song_id"];
    this.filePath = await downloadFromBucket(fileUrl, fileId);
    this.backingTrackPath = await downloadFromBucket(fileUrl, fileId, backingTrack: true);
    // print("filePath for song: ${this.filePath}");
  }
}
