import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class CreatableSongs with ChangeNotifier {
  List<CreatableSong> all = [];

  static String getFullName(theName, theStyle) {
    if (theStyle == "")
      return theName;
    else
      return "$theName ($theStyle)";
  }

  CreatableSong dataMatchesSong(data) {
    return all.firstWhere(
        (existing) =>
            existing.fullName == getFullName(data["name"], data["style"]),
        orElse: () => null);
  }

  void createNewSong(data) {
    var newSong = CreatableSong(
      name: data["name"],
      style: data["style"],
      arrangement: {data["arrangement"]: data["id"]},
      backingTrackUrl: "backing_tracks/${data["backing_track"]}/0.aac",
      backingTrackOffset: data["backingtrack_offset"],
    );
    all.add(newSong);
  }

  void addSongArrangement(existing, newData) {
    var newArrangement = newData["arrangement"];
    var newId = newData["id"];
    existing.arrangement[newArrangement] = newId;
  }

  Future<void> retrieveFromServer() async {
    List data = await RestAPI.retrieveAllCreatableSongs();
    // creatable songs have two arrangements which exist as separate songs on the server. They are combined on the frontend into one song with two versions.
    data.forEach((songData) {
      CreatableSong existing = dataMatchesSong(songData);
      if (existing == null) {
        createNewSong(songData);
      } else {
        addSongArrangement(existing, songData);
      }
    });
    notifyListeners();
  }
}

class CreatableSong {
  final String name;
  final String style;
  final String backingTrackUrl;
  final int backingTrackOffset;
  final Map arrangement; // {"harmonized": "someId", "pitched": "someId"}

  CreatableSong(
      {this.name,
      this.style,
      this.backingTrackUrl,
      this.arrangement,
      this.backingTrackOffset});

  List<int> get ids {
    return [arrangement["harmonized"], arrangement["pitched"]];
  }

  String get fullName {
    return CreatableSongs.getFullName(name, style);
  }
}
