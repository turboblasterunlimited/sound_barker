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
}

class CurrentActivity with ChangeNotifier {
  bool cardCreation = false;
  bool songLibrary = false;
  bool barkLibrary = false;
  CardCreationSteps cardCreationStep;
  CardCreationSubSteps cardCreationSubStep;

  bool activitySelected() {
    return cardCreation || songLibrary || barkLibrary;
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

  void setCardCreationStep(CardCreationSteps step) {
    cardCreationStep = step;
    cardCreationSubStep = CardCreationSubSteps.one;
    notifyListeners();
  }

  void setCardCreationSubStep(CardCreationSubSteps subStep) {
    cardCreationSubStep = subStep;
    notifyListeners();
  }

  void setPreviousSubStep() {
    setCardCreationSubStep(CardCreationSubSteps.values[cardCreationSubStep.index - 1]);
  }

    void setNextSubStep() {
    setCardCreationSubStep(CardCreationSubSteps.values[cardCreationSubStep.index + 1]);
  }

  void startCreateCard(Function setCurrentCardCallback) {
    setCurrentCardCallback();
    cardCreationStep = CardCreationSteps.snap;
    cardCreation = true;
    songLibrary = false;
    barkLibrary = false;
    notifyListeners();
  }

  void startSongLibrary() {
    cardCreation = false;
    songLibrary = true;
    barkLibrary = false;
    notifyListeners();
  }

  void startBarkLibrary() {
    cardCreation = false;
    songLibrary = false;
    barkLibrary = true;
    notifyListeners();
  }
}
