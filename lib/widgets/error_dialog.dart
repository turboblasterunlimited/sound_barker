import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showError(BuildContext context,
    [String message = "You must be connected to the internet"]) {
  print("within show Error start");
  print("message is: $message");
  SystemChrome.setEnabledSystemUIOverlays([]);
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
  print("within show Error end");
}
