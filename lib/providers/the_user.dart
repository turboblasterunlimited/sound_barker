import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';

class TheUser with ChangeNotifier {
  String email;
  bool filesLoaded = false;

  TheUser({this.email});

  Future<dynamic> logout() async {
    email = null;
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

  Future<dynamic> delete() async {
    var oldEmail = email;
    email = null;
    return await RestAPI.deleteUser(oldEmail);
  }
}
