import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import './bark.dart';
import './song.dart';

class Pet with ChangeNotifier {
  String name;
  String imageUrl;
  final String id = Uuid().v4();
  List<Bark> barks = [];
  List<Song> songs = [];
  Pet({this.name});

  void addBark(Bark bark) {
    barks.add(bark);
  }

  void removeBark(barkToDelete) {
    barks.removeWhere((bark) {
      return bark.name == barkToDelete.name;
    });
  }
}
