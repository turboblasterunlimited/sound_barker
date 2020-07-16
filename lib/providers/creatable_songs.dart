import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class CreatableSongs with ChangeNotifier {
  List all = [];

  bool dataMatchesSong(data) {
    return all.firstWhere(
        (existing) => existing.fullName == data["name"] + " " + data["style"],
        orElse: () => null);
  }

  void createNewSong(data) {
    var newSong = CreatableSong(
        name: data["name"],
        style: data["style"],
        arrangement: {data["arrangement"]: data["id"]}
        );
    all.add(newSong);
  }

  void addSongArrangement(existing, newData) {
    var newArrangement = newData["arrangement"];
    var newId = newData["id"];
    existing.arrangement[newArrangement] = newId;
  }

  void retrieveFromServer() async {
    List data = await RestAPI.retrieveAllCreatableSongsFromServer();
    data.forEach((songData) {
      var existing = dataMatchesSong(songData);
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
  final Map arrangement; // {"harmonized": "someId", "pitched": "someId"}

  CreatableSong({this.name, this.style, this.arrangement});

  String get fullName {
    return name + " " + style;
  }
}