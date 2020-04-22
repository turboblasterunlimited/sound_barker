import 'package:flutter/material.dart';

class TabListScrollController with ChangeNotifier {
  ScrollController scrollController;
  double tabExtent = 0.5;

  void setScrollController(scrollController) {
    this.scrollController = scrollController;
  }

  void updateTabExtent(double extent) {
    this.tabExtent = extent;
  }
}
