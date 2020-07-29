import 'package:flutter/material.dart';

void showError(context, [message = "You must be connected to the internet"]) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }