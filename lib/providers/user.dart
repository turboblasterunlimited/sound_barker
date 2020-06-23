import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String email;

  User({this.email});

  bool isSignedIn() {
    print("email is: $email");
    return email != null;
  }
  void signIn(userEmail) {
    email = userEmail;
    notifyListeners();
  }
}
