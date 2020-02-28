import 'package:flutter/foundation.dart';
import '../services/gcloud.dart';
import 'dart:convert';

import '../services/rest_api.dart';

class Songs with ChangeNotifier, Gcloud {
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

  void downloadAllSongsFromBucket([List songs]) async {
    songs = songs == null ? all : songs;
    int soundCount = songs.length;
    for (var i = 0; i < soundCount; i++) {
      String filePath =
          await downloadSoundFromBucket(songs[i].fileUrl, songs[i].fileId);
      songs[i].filePath = filePath;
      // print("filePath for song: $filePath");
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

  void playSong() {}

  Future<List> renameSong(responseBody) async {
    try {
      await renameSongOnServer(this);
    } catch (e) {
      throw e;
    }
    this.name = name;
    notifyListeners();
  }

  Future<List> retrieveSong(responseBody) async {
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
