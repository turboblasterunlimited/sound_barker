import 'package:K9_Karaoke/classes/drawing.dart';
import 'package:K9_Karaoke/classes/typing.dart';

class CardDecoration {
  List<Drawing> drawings = [];
  List<Typing> typings = [];

  CardDecoration();

  bool get isEmpty {
    return drawings.isEmpty && typings.isEmpty;
  }

  void removeEmptyTypings() {
    List<Typing> result = [];
    typings.forEach((typing) {
      if (!typing.isEmpty()) result.add(typing);
    });
    typings = result;
  }
}
