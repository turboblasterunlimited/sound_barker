import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class CreatableSongs with ChangeNotifier {
  List<CreatableSong> all = [];

  void sort() {
    print("sorting creatables");
    all.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    print("done sorting");
  }

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
      displayOrder: data["display_order"],
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
    print("creatable song data: $data");
    // creatable songs have two arrangements which exist as separate songs on the server. They are combined on the frontend into one song with two versions.
    data.forEach((songData) {
            print("checkpoint");

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
  final String name; // "Happy Birthday"
  final String style; // "Guitar"
  final String backingTrackUrl;
  final int backingTrackOffset;
  final Map arrangement; // {"harmonized": "someId", "pitched": "someId"}
  final int displayOrder;

  CreatableSong(
      {this.name,
      this.style,
      this.backingTrackUrl,
      this.arrangement,
      this.backingTrackOffset,
      this.displayOrder});

  List<int> get ids {
    return [arrangement["harmonized"], arrangement["pitched"]];
  }

  String get fullName {
    return CreatableSongs.getFullName(name, style);
  }
}
