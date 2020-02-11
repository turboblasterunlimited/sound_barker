import './bark.dart';
import 'package:flutter/foundation.dart';

class Barks with ChangeNotifier {
  List<Bark> _savedBarks = [Bark('/', 'Rufus'), Bark('/', 'Troutman')];

  void addBark(Bark bark) {
    _savedBarks.add(bark);
  }

  List<Bark> get savedBarks {
    return [..._savedBarks];
  }

  void removeBark(barkToDelete) {
    _savedBarks.removeWhere((bark) {
      return bark.title == barkToDelete.title;
    });
  }
  
}
