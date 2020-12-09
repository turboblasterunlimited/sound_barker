import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TheUser with ChangeNotifier {
  // NEED TO ADD USER APP ID (UUID) FOR PURCHASES INSTEAD OF EMAIL.
  String email;
  bool filesLoaded = false;
  PurchaserInfo purchaserInfo;
  List<Package> packages;

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
    _initPurchases();
    notifyListeners();
  }

  Future<dynamic> delete() async {
    var oldEmail = email;
    email = null;
    return await RestAPI.deleteUser(oldEmail);
  }

  // email needs to be replaced with user app UUID
  Future<void> _initPurchases() async {
    try {
      print("Starting init purchase");
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.setup("kfQNBpPMjButvkTYkSYizepoXBCjLBxA",
          appUserId: email);
      await _getPurchases();
    } catch (e) {
      print("init purchase failed: $e");
    }
    Purchases.addPurchaserInfoUpdateListener((info) {
      print("Purchaser info updated: $info");
    });
  }

  Future _getPurchases() async {
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print("Get Purchaser success: $purchaserInfo");
    } catch (e) {
      print("Get purchaser error: $e");
    }
  }

  Future<List> getOfferings() async {
    if (packages != null) return packages;
    try {
      print("Getting offereings");
      Offerings offerings = await Purchases.getOfferings();
      print("Offerings: $offerings");
      if (offerings.current == null) return null;
      packages = offerings.current.availablePackages;
      if (packages.isEmpty) return null;
      print("offerings available: $packages");
      return packages;
    } catch (e) {
      print("get offerings error: $e");
    }
  }

  bool get hasActiveSubscription {
    return purchaserInfo.entitlements.active.isNotEmpty;
  }
}
