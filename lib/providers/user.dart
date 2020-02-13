import 'package:flutter/foundation.dart';

import './pet.dart';

class User with ChangeNotifier {
  String email = 'tovi@gmail.com';
  List<Pet> _pets = [
    Pet(name: "Fido", imageUrl: 'http://cdn.akc.org/content/article-body-image/samoyed_puppy_dog_pictures.jpg'), 
    Pet(name: "Bilbo", imageUrl: 'https://s3.amazonaws.com/cdn-origin-etr.akc.org/wp-content/uploads/2018/01/12201051/cute-puppy-body-image.jpg') 
  ];

   List<Pet> get pets {
    return [..._pets];
  }

  void addPet(Pet pet) {
    _pets.add(pet);
  }

  int petCount() {
    return _pets.length;
  }

}