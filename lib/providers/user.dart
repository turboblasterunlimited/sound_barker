import 'package:flutter/foundation.dart';

import './pet.dart';
import './bark.dart';

class User with ChangeNotifier {
  String email = 'tovi@gmail.com';
  String id = '999';
  List<Pet> _pets = [];

  List<String> allPetNames() {
    return pets.map((pet) => pet.name);
  }
  List<Bark> allBarks() {
    final List<Bark> allBarks = [];
    _pets.forEach((pet) => allBarks.addAll(pet.barks));
    return allBarks;
  }

  List<Pet> get pets {
    return [..._pets];
  }

  void addPet(Pet pet) {
    _pets.add(pet);
  }

  Map<String, String>allPetNameIdPairs() {
    Map<String, String> result;
    pets.forEach((pet) {
      result.putIfAbsent(pet.name, () => pet.id);
    });
    return result;
  }

  int petCount() {
    return _pets.length;
  }
}
