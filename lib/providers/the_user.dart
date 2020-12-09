import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TheUser with ChangeNotifier {
  // NEED TO ADD USER APP ID (UUID) FOR PURCHASES INSTEAD OF EMAIL.
  String email;
  bool filesLoaded = false;
  PurchaserInfo purchaserInfo;

  TheUser({this.email});

  Future<dynamic> logout() async {
    email = null;
    Purchases.reset();
    return await RestAPI.logoutUser(email);
  }

  bool isSignedIn() {
    print("email from within: $email");
    return email != null;
  }

  void signIn(userEmail) {
    email = userEmail;
    print("signIn email from within: $email");
    initPurchases();
    notifyListeners();
  }

  Future<dynamic> delete() async {
    var oldEmail = email;
    email = null;
    return await RestAPI.deleteUser(oldEmail);
  }

  // email needs to be replaced with user app UUID
  Future<void> initPurchases() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("kfQNBpPMjButvkTYkSYizepoXBCjLBxA", appUserId: email);
    await getPurchases();
  }

  Future getPurchases() async {
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print("Get Purchaser success: $purchaserInfo");
    } catch (e) {
      print("Get purchaser error: $e");
    }
  }

  bool get hasActiveSubscription {
    return purchaserInfo.entitlements.active.isNotEmpty;
  }
}
