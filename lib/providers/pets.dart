import 'package:flutter/foundation.dart';
import 'dart:convert';

import './barks.dart';
import './song.dart';
import '../services/gcloud.dart';
import '../services/rest_api.dart';

class Pets with ChangeNotifier {
  List<Pet> all = [];

  Pet getById(id) {
    return all.firstWhere((pet) => pet.id == id);
  }

// Delete this nonsense after deleting radio button implementation.
  Map<String, String> allPetNameIdPairs() {
    Map<String, String> result = {};
    all.forEach((pet) {
      result.putIfAbsent(pet.name, () => pet.id);
    });
    return result;
  }

  List<String> allPetNames() {
    return all.map((pet) => pet.name);
  }
}

class Pet with ChangeNotifier, Gcloud, RestAPI {
  String name;
  String imageUrl;
  String id;
  List<Bark> barks = [];
  List<Song> songs = [];
  Pet({this.name});

  Future<Pet> createAndSyncWithServer() async {
    String responseBody = await this.createPetOnServer(name);
    //print(responseBody);
    int petId = json.decode(responseBody)["pet_id"];
    this.id = petId.toString();
    return this;
  }

  void addBark(Bark bark) {
    barks.add(bark);
    notifyListeners();
  }

  void addSong(Song song) {
    songs.add(song);
    notifyListeners();
  }

  void removeBark(barkToDelete) {
    barks.removeWhere((bark) {
      return bark.fileId == barkToDelete.fileId;
    });
    notifyListeners();
  }
}
