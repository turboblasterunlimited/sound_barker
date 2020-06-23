import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String email;

  User({this.email});

  bool isSignedIn() {
    print("email from within: $email");
    return email != null;
  }
  void signIn(userEmail) {
    email = userEmail;
    print("signIn email from within: $email");
    notifyListeners();
  }
}
