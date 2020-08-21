import 'package:K9_Karaoke/classes/drawing.dart';
import 'package:K9_Karaoke/classes/typing.dart';

class CardDecoration {
  List<Drawing> drawings = [];
  List<Typing> typings = [];

  CardDecoration() {
    print("typings: $typings");
    print("drawings: $drawings");
  }

  bool get isEmpty {
    return drawings.isEmpty && typings.isEmpty;
  }
}
