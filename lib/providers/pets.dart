import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import './barks.dart';
import './song.dart';

class Pets with ChangeNotifier {
  List<Pet> all = [];

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

class Pet with ChangeNotifier {
  String name;
  String imageUrl;
  final String id = Uuid().v4();
  List<Bark> barks = [];
  List<Song> songs = [];
  Pet({this.name});

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
