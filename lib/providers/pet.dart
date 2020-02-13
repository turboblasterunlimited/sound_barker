import 'package:flutter/foundation.dart';

import './bark.dart';
import './song.dart';

class Pet with ChangeNotifier {
  List<Bark> _savedBarks = [];
  List<Song> _savedSongs = [];
  String _name;

  String get name {
    return _name;
  }

  List<Bark> get savedBarks {
    return [..._savedBarks];
  }

  List<Song> get savedSongs {
    return [..._savedSongs];
  }

  void addBark(Bark bark) {
    _savedBarks.add(bark);
  }

  void removeBark(barkToDelete) {
    _savedBarks.removeWhere((bark) {
      return bark.name == barkToDelete.name;
    });
  }
}
