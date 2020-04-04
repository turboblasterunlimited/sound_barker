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
    Bucket bucket = await accessBucket();
    songs = songs == null ? all : songs;
    int soundCount = songs.length;
    for (var i = 0; i < soundCount; i++) {
      String filePath =
          await downloadFromBucket(songs[i].fileUrl, songs[i].fileId, image: false, bucket: bucket);
      songs[i].filePath = filePath;
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

  Song({this.filePath, this.name, this.fileUrl, this.fileId, this.formulaId});

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
    this.fileId = responseData["uuid"];
    this.name = responseData["name"];
    this.fileUrl = responseData["bucket_fp"];
    this.formulaId = responseData["song_id"];
    this.filePath = await downloadFromBucket(fileUrl, fileId, image: false);
    // print("filePath for song: ${this.filePath}");
  }
}
