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

  Future<bool> hasAgreedToTerms(userEmail) async {
    print("Getting user...");
    var response = await RestAPI.getUser(userEmail);
    print("get user response: $response");
    return response["user_agreed_to_terms_v1"] == 1;
  }

  Future<bool> agreeToTerms() async {
    var response = await RestAPI.agreeToTerms();
    return response["success"];
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

  makePurchase(package) async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      if (purchaserInfo
          .entitlements.all["my_entitlement_identifier"].isActive) {
        // Unlock that great "pro" content
      }
    } catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Something went wrong with purchase");
      }
    }
  }

  bool get hasActiveSubscription {
    return purchaserInfo.entitlements.active.isNotEmpty;
  }
}

// "Offerings"{
//    "current":"Offering"{
//       "identifier":"Monthly",
//       "serverDescription":"Pay for Karaoke UNLIMITED with a monthly subscription.",
//       "availablePackages":[
//          "Package"{
//             "identifier":"$rc_monthly",
//             "packageType":"PackageType.monthly",
//             "product":"Product"{
//                "identifier":1m_399,
//                "description":"Save and send UNLIMITED Karaoke cards.",
//                "title":"Karaoke UNLIMITED",
//                "price":3.990000009536743,
//                "priceString":$3.99,
//                "currencyCode":"USD",
//                "introductoryPrice":null
//             },
//             "offeringIdentifier":"Monthly"
//          }
//       ],
//       "lifetime":null,
//       "annual":null,
//       "sixMonth":null,
//       "threeMonth":null,
//       "twoMonth":null,
//       "monthly":"Package"{
//          "identifier":"$rc_monthly",
//          "packageType":"PackageType.monthly",
//          "product":"Product"{
//             "identifier":1m_399,
//             "description":"Save and send UNLIMITED Karaoke cards.",
//             "title":"Karaoke UNLIMITED",
//             "price":3.990000009536743,
//             "priceString":$3.99,
//             "currencyCode":"USD",
//             "introductoryPrice":null
//          },
//          "offeringIdentifier":"Monthly"
//       },
//       "weekly":null
//    },
//    "all":{
//       "Monthly":"Offering"{
//          "identifier":"Monthly",
//          "serverDescription":"Pay for Karaoke UNLIMITED with a monthly subscription.",
//          "availablePackages":[
//             "Package"{
//                "identifier":"$rc_monthly",
//                "packageType":"PackageType.monthly",
//                "product":"Product"{
//                   "identifier":1m_399,
//                   "description":"Save and send UNLIMITED Karaoke cards.",
//                   "title":"Karaoke UNLIMITED",
//                   "price":3.990000009536743,
//                   "priceString":$3.99,
//                   "currencyCode":"USD",
//                   "introductoryPrice":null
//                },
//                "offeringIdentifier":"Monthly"
//             }
//          ],
//          "lifetime":null,
//          "annual":null,
//          "sixMonth":null,
//          "threeMonth":null,
//          "twoMonth":null,
//          "monthly":"Package"{
//             "identifier":"$rc_monthly",
//             "packageType":"PackageType.monthly",
//             "product":"Product"{
//                "identifier":1m_399,
//                "description":"Save and send UNLIMITED Karaoke cards.",
//                "title":"Karaoke UNLIMITED",
//                "price":3.990000009536743,
//                "priceString":$3.99,
//                "currencyCode":"USD",
//                "introductoryPrice":null
//             },
//             "offeringIdentifier":"Monthly"
//          },
//          "weekly":null
//       },
//       "Annually":"Offering"{
//          "identifier":"Annually",
//          "serverDescription":"Pay for Karaoke UNLIMITED with an annual subscription.",
//          "availablePackages":[
//             "Package"{
//                "identifier":"$rc_annual",
//                "packageType":"PackageType.annual",
//                "product":"Product"{
//                   "identifier":1y_2499,
//                   "description":"Save and send UNLIMITED Karaoke Cards.",
//                   "title":"Karaoke UNLIMITED",
//                   "price":24.489999771118164,
//                   "priceString":$24.49,
//                   "currencyCode":"USD",
//                   "introductoryPrice":null
//                },
//                "offeringIdentifier":"Annually"
//             }
//          ],
//          "lifetime":null,
//          "annual":"Package"{
//             "identifier":"$rc_annual",
//             "packageType":"PackageType.annual",
//             "product":"Product"{
//                "identifier":1y_2499,
//                "description":"Save and send UNLIMITED Karaoke Cards.",
//                "title":"Karaoke UNLIMITED",
//                "price":24.489999771118164,
//                "priceString":$24.49,
//                "currencyCode":"USD",
//                "introductoryPrice":null
//             },
//             "offeringIdentifier":"Annually"
//          },
//          "sixMonth":null,
//          "threeMonth":null,
//          "twoMonth":null,
//          "monthly":null,
//          "weekly":null
//       }
//    }
// }
