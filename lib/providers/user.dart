import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String email;
  bool filesLoaded = false;

  User({this.email});

  dynamic logout() async {
    return await RestAPI.logoutUser(email);
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
