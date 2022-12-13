import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:purchases_flutter/purchases_flutter.dart';

class TheUser with ChangeNotifier {
  // NEED TO ADD USER APP ID (UUID) FOR PURCHASES INSTEAD OF EMAIL.
  String? email;
  String? uuid;
  String? account_type;
  String? apple_proxy_email;
  bool? agreedToTerms;
  PurchaserInfo? purchaserInfo;
  List<Package>? availablePackages;
  late Offerings offerings;
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

  Future<void> signIn(Map userObj) async {
    account_type = userObj["account_type"];
    email = userObj["user_id"];
    apple_proxy_email = userObj["email"];
    agreedToTerms = userObj["user_agreed_to_terms_v1"] == 1;
    uuid = userObj["account_uuid"];
    await _initPurchases();
    notifyListeners();
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

  Package? matchCrossPlatformSubscription(String sku) {
    Package? package;
    for (var i = 0; i < availablePackages!.length; i++) {
      package = availablePackages![i];
      String candidate = package.product.identifier;
      // match 39 for monthly and 24 for yearly subscriptions
      // this compensates for mismatch in strings
      candidate = candidate.substring(3, 5);
      var test = sku.substring(3, 5);
      if (test == candidate) {
        break; // found package
      }
    }
    return package;
  }

  String getSubscriptionProvider() {
    String result = "No subscription";
    if (purchaserInfo!.activeSubscriptions.isNotEmpty) {
      String sku = purchaserInfo!.activeSubscriptions[0];
      // hack to differentiate who subscription purchased from
      result = sku.substring(0, 2) == "k9" ? "google" : "apple";
    }
    return result;
  }

  Package? getActivePackage() {
    if (purchaserInfo!.activeSubscriptions.isEmpty) return null;
    String sku = purchaserInfo!.activeSubscriptions[0];
    Package? activePackage = matchCrossPlatformSubscription(sku);
    // Package activePackage = availablePackages!
    //     .firstWhere((Package package) => package.product.identifier == sku);
    print("active Package: $activePackage");
    return activePackage;
  }

  // monthly OR yearly
  String getSubscriptionName() {
    if (getActivePackage() == null) {
      return "";
    }
    return getActivePackage()!.packageType.toString().split('.').last;
  }

  List<Package>? getInactivePackages() {
    print("Getting inactive packages");
    Package? activePackage = getActivePackage();
    List<Package> remainingPackages =
        (availablePackages != null ? availablePackages!.toList() : null)!;
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
    if (availablePackages != null) return /* jmf 12-22-21 availablePackages */;
    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current == null) return;
      availablePackages = offerings.current!.availablePackages;
      if (availablePackages!.isEmpty) return;
    } catch (e) {
      print("get offerings error: $e");
    }
  }

  makePurchase(package, errorCallback) async {
    isLoading = true;
    notifyListeners();
    print("Attempting Purchase");
    try {
      purchaserInfo = await Purchases.purchasePackage(package);
      //print(pinfo);
      print("Purchaser info: $purchaserInfo");
    } catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e as PlatformException);
      errorCallback(errorCode.toString());
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        errorCallback("Purchase Failed");
      }
    }
    isLoading = false;
    notifyListeners();
  }

  bool get subscribed {
    // return true;
    if (purchaserInfo == null) return false;
    print("User's active subscriptions: ${purchaserInfo!.entitlements.active}");
    return purchaserInfo!.entitlements.active.isNotEmpty;
  }
}
