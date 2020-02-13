import 'package:flutter/foundation.dart';

import './bark.dart';
import './song.dart';

class Pet with ChangeNotifier {
  List<Bark> savedBarks = [];
  List<Song> savedSongs = [];
  String name;
  String imageUrl;

  Pet({this.name, this.imageUrl});

  void addBark(Bark bark) {
    savedBarks.add(bark);
  }

  void removeBark(barkToDelete) {
    savedBarks.removeWhere((bark) {
      return bark.name == barkToDelete.name;
    });
  }
}
