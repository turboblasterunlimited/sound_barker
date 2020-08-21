import 'package:K9_Karaoke/classes/drawing.dart';
import 'package:K9_Karaoke/classes/typing.dart';

class CardDecoration {
  List<Drawing> drawings = [];
  List<Typing> typings = [];

  bool get isEmpty {
    return drawings.isEmpty && typings.isEmpty;
  }
}
