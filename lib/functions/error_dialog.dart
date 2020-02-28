import 'package:flutter/material.dart';

showErrorDialog(BuildContext context, String error) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Error"),
        content: Text(error),
        actions: [
          FlatButton(
            child: Text("OK"),
            onPressed: () {},
          ),
        ],
      );
    },
  );
}
