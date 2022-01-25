import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class CreatableSongs with ChangeNotifier {
  List<CreatableSong> all = [];
  CreatableSong? _nullSong;

  CreatableSong nullSong() {
    if (_nullSong == null) {
      _nullSong = CreatableSong(
        name: "",
        style: "",
        arrangement: {"arrangement": 0},
        backingTrackUrl: "",
        backingTrackOffset: 0,
        displayOrder: 0,
      );
    }
    return _nullSong!;
  }

  void sort() {
    print("sorting creatables");
    all.sort((a, b) => a.fullName.compareTo(b.fullName));
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
        orElse: () => nullSong());
  }

  void createNewSong(data) {
    var newSong = CreatableSong(
      name: data["name"],
      style: data["style"],
      arrangement: {data["arrangement"]: data["id"]},
      backingTrackUrl: "backing_tracks/${data["backing_track"]}/0.aac",
      backingTrackOffset:
          data["backingtrack_offset"] != null ? data["backingtrack_offset"] : 0,
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
    // creatable songs have two arrangements which exist as separate songs on the server. They are combined on the frontend into one song with two versions.
    data.forEach((songData) {
      print("checkpoint");

      CreatableSong existing = dataMatchesSong(songData);
      if (existing.isNull()) {
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
      {required this.name,
      required this.style,
      required this.backingTrackUrl,
      required this.arrangement,
      required this.backingTrackOffset,
      required this.displayOrder});

  List<int> get ids {
    return [arrangement["harmonized"], arrangement["pitched"]];
  }

  String get fullName {
    return CreatableSongs.getFullName(name, style);
  }

  bool isNull() {
    return this.name.isEmpty;
  }
}
