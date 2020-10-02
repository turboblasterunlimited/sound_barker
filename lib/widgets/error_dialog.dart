import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showError(context, [message = "You must be connected to the internet"]) {
  SystemChrome.setEnabledSystemUIOverlays([]);
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
