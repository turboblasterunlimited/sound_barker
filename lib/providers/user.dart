import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String email;
  bool filesLoaded = false;

  User({this.email});

  void setLoadFilesTrue() {
    filesLoaded = true;
    notifyListeners();
  }

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
