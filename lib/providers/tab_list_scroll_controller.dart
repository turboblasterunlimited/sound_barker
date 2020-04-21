import 'package:flutter/material.dart';

class TabListScrollController with ChangeNotifier {
  ScrollController scrollController;

  void setController(controller) {
    this.scrollController = controller;
  }

  ScrollController get controller {
    return scrollController;
  }
}