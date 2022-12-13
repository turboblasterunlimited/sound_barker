import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showError(BuildContext context,
    [String message = "You must be connected to the internet"]) {
  print("message is: $message");
  SystemChrome.setEnabledSystemUIOverlays([]);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
  print("within show Error end");
}
