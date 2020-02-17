import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import './barks.dart';
import './song.dart';
import './gcloud.dart';
import './rest_api.dart';

class Pets with ChangeNotifier {
  List<Pet> all = [];

  Pet getById(id) {
    return all.firstWhere((pet) => pet.id == id);
  }

  Map<String, String>allPetNameIdPairs() {
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
    String petId = json.decode(responseBody)["pet_id"];
    this.id = petId;
    return this;
  }

  void addBark(Bark bark) {
    barks.add(bark);
    notifyListeners();
  }

  void removeBark(barkToDelete) {
    barks.removeWhere((bark) {
      return bark.name == barkToDelete.name;
    });
  }



}
