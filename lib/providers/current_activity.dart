import 'package:flutter/foundation.dart';

enum CardCreationSteps {
  snap,
  song,
  speak,
  style,
}

enum CardCreationSubSteps {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
}

// Currently this is just to detect whether the menu 
// screen can be popped to reveal the main screen.
enum Activities {
  cardCreation,
}

enum CardType {
  newSong,
  oldSong,
  justMessage,
}

class CurrentActivity with ChangeNotifier {
  Activities current;
  CardCreationSteps cardCreationStep;
  CardCreationSubSteps cardCreationSubStep;
  CardType cardType;

  // Activities
  bool get isCreateCard {
    return Activities.cardCreation == current;
  }

  // Substeps
  bool get isOne {
    return cardCreationSubStep == CardCreationSubSteps.one;
  }

  bool get isTwo {
    return cardCreationSubStep == CardCreationSubSteps.two;
  }

  bool get isThree {
    return cardCreationSubStep == CardCreationSubSteps.three;
  }

  bool get isFour {
    return cardCreationSubStep == CardCreationSubSteps.four;
  }

  bool get isFive {
    return cardCreationSubStep == CardCreationSubSteps.five;
  }

  bool get isSix {
    return cardCreationSubStep == CardCreationSubSteps.six;
  }

  bool get isSeven {
    return cardCreationSubStep == CardCreationSubSteps.seven;
  }

  // Steps
  bool get isSnap {
    return cardCreationStep == CardCreationSteps.snap;
  }

  bool get isSong {
    return cardCreationStep == CardCreationSteps.song;
  }

  bool get isSpeak {
    return cardCreationStep == CardCreationSteps.speak;
  }

  bool get isStyle {
    return cardCreationStep == CardCreationSteps.style;
  }

  void setCardCreationStep(CardCreationSteps step,
      [CardCreationSubSteps subStep]) {
    cardCreationStep = step;
    subStep == null
        ? cardCreationSubStep = CardCreationSubSteps.one
        : cardCreationSubStep = subStep;
    notifyListeners();
  }

  void setCardCreationSubStep(CardCreationSubSteps subStep) {
    cardCreationSubStep = subStep;
    notifyListeners();
  }

  void setPreviousSubStep() {
    setCardCreationSubStep(
        CardCreationSubSteps.values[cardCreationSubStep.index - 1]);
  }

  void setNextSubStep() {
    setCardCreationSubStep(
        CardCreationSubSteps.values[cardCreationSubStep.index + 1]);
  }

  void startCreateCard() {
    cardCreationStep = CardCreationSteps.snap;
    current = Activities.cardCreation;
    notifyListeners();
  }
}
