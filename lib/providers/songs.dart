import 'package:flutter/foundation.dart';
import '../services/gcloud.dart';
import 'dart:convert';
import 'dart:io';

import '../services/rest_api.dart';

class Songs with ChangeNotifier, Gcloud, RestAPI {
  List<Song> all = [];

  void addSong(bark) {
    all.add(bark);
    notifyListeners();
    //print("All the barks: $all");
  }

  void removeSong(songToDelete) {
    all.removeWhere((song) {
      return song.fileId == songToDelete.fileId;
    });
    notifyListeners();
  }

  // ALL SONGS THAT AREN'T HIDDEN UNLESS THEY EXIST
  Future retrieveAllSongs() async {
    String response = await retrieveAllSongsFromServer();
    json.decode(response).forEach((serverSong) {
      if(serverSong["hidden"] == "1") return;
      Song song = Song(name: serverSong["name"], fileUrl: serverSong["bucket_fp"], fileId: serverSong["crop_id"]);
      if (all.indexWhere((song) => song.fileId == serverSong["crop_id"]) == -1) {
        all.add(song);
      }
    });
    await _downloadAllSongsFromBucket();
    notifyListeners();
  }

  // downloadSoundFromBucket only downloads songs that don't already exist on the FS
  Future _downloadAllSongsFromBucket([List songs]) async {
    songs = songs == null ? all : songs;
    int soundCount = songs.length;
    for (var i = 0; i < soundCount; i++) {
      String filePath =
          await downloadSoundFromBucket(songs[i].fileUrl, songs[i].fileId);
      songs[i].filePath = filePath;
    }
  }
}

class Song with ChangeNotifier, Gcloud, RestAPI {
  String name;
  String fileUrl;
  String filePath;
  String fileId;
  String petId;

  Song({this.filePath, this.name, this.fileUrl, this.fileId, this.petId});

  void removeFromStorage() {
    try {
      File(filePath).deleteSync(recursive: false);
    } catch (e) {
      print(e);
    }
  }

  Future<String> deleteFromServer() {
    return deleteSongFromServer(this);
  }

  void rename(newName) async {
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
    this.petId = responseData["pet_id"].toString();
    this.name = responseData["name"];
    this.fileUrl = responseData["bucket_fp"];
    this.filePath = await downloadSoundFromBucket(fileUrl, fileId);
    // print("filePath for song: ${this.filePath}");
  }
}
