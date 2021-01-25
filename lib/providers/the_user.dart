import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TheUser with ChangeNotifier {
  // NEED TO ADD USER APP ID (UUID) FOR PURCHASES INSTEAD OF EMAIL.
  String email;
  String uuid;
  bool agreedToTerms;
  PurchaserInfo purchaserInfo;
  List<Package> availablePackages;
  Offerings offerings;
  bool isLoading = false;
  bool filesLoaded = false;

  Future<dynamic> logout() async {
    email = null;
    Purchases.reset();
    return await RestAPI.logoutUser(email);
  }

  Future<bool> agreeToTerms() async {
    var response = await RestAPI.agreeToTerms();
    return response["success"];
  }

  bool isSignedIn() {
    print("email from within: $email");
    return email != null;
  }

  void signIn(Map userObj) {
    email = userObj["user_id"];
    agreedToTerms = userObj["user_agreed_to_terms_v1"] == 1;
    uuid = userObj["account_uuid"];
    _initPurchases();
    notifyListeners();
    print("completed sign in");
  }

  Future<dynamic> delete() async {
    var oldEmail = email;
    email = null;
    return await RestAPI.deleteUser(oldEmail);
  }

  // REVENUECAT PURCHASE LOGIC
  Future<void> _initPurchases() async {
    try {
      print("Starting init purchase");
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.setup("kfQNBpPMjButvkTYkSYizepoXBCjLBxA",
          appUserId: email);
      await _getPurchases();
      await getPackages();
      print("Purchaser info: $purchaserInfo");
    } catch (e) {
      print("init purchase failed: $e");
    }
    Purchases.addPurchaserInfoUpdateListener((PurchaserInfo info) {
      purchaserInfo = info;
      notifyListeners();
    });
  }

  Package getActivePackage() {
    if (purchaserInfo.activeSubscriptions.isEmpty) return null;
    String sku = purchaserInfo.activeSubscriptions[0];
    Package activePackage = availablePackages
        .firstWhere((Package package) => package.product.identifier == sku);
    print("active Package: $activePackage");
    return activePackage;
  }

  List<Package> getInactivePackages() {
    print("Getting inactive packages");
    Package activePackage = getActivePackage();
    List<Package> remainingPackages = availablePackages.toList();
    print("packages: $remainingPackages");
    print("active packages: $activePackage");

    if (activePackage != null) {
      remainingPackages.remove(activePackage);
    }
    return remainingPackages;
  }

  Future _getPurchases() async {
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print("Get Purchaser success: $purchaserInfo");
    } catch (e) {
      print("Get purchaser error: $e");
    }
  }

  Future<void> getPackages() async {
    if (availablePackages != null) return availablePackages;
    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current == null) return null;
      availablePackages = offerings.current.availablePackages;
      if (availablePackages.isEmpty) return null;
    } catch (e) {
      print("get offerings error: $e");
    }
  }

  makePurchase(package, errorCallback) async {
    isLoading = true;
    notifyListeners();
    print("Attempting Purchase");
    try {
      await Purchases.purchasePackage(package);
      print("Purchaser info: $purchaserInfo");
    } catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      errorCallback(errorCode.toString());
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        errorCallback("Purchase Failed");
      }
    }
    isLoading = false;
    notifyListeners();
  }

  bool get subscribed {
    if (purchaserInfo == null) return false;
    print("User's active subscriptions: ${purchaserInfo.entitlements.active}");
    return purchaserInfo.entitlements.active.isNotEmpty;
  }
}
