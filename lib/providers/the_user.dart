import 'package:K9_Karaoke/services/rest_api.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class TheUser with ChangeNotifier {
  // NEED TO ADD USER APP ID (UUID) FOR PURCHASES INSTEAD OF EMAIL.
  String email;
  bool filesLoaded = false;
  PurchaserInfo purchaserInfo;
  List<Package> availablePackages;
  Offerings offerings;

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

  // REVENUECAT PURCHASE LOGIC

  // email needs to be replaced with user app UUID
  Future<void> _initPurchases() async {
    try {
      print("Starting init purchase");
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.setup("kfQNBpPMjButvkTYkSYizepoXBCjLBxA",

          // email needs to be replaced with user app UUID
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
    String sku = purchaserInfo.activeSubscriptions[0];
    Package activePackage = availablePackages
        .firstWhere((Package package) => package.product.identifier == sku);
    print("active Package: $activePackage");
    return activePackage;
  }

  List<Package> getInactivePackages() {
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

  makePurchase(package) async {
    print("Attempting Purchase");
    try {
      await Purchases.purchasePackage(package);
      print("Purchaser info: $purchaserInfo");
      if (hasActiveSubscription) {
        print("Unlock Unlimited");
      }
      notifyListeners();
    } catch (e) {
      print("Something went wrong");
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      print("Something went wrong with purchase. Error: $errorCode");
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Something went wrong with purchase");
      }
    }
  }

  bool get hasActiveSubscription {
    print("User's active subscriptions: ${purchaserInfo.entitlements.active}");
    return purchaserInfo.entitlements.active.isNotEmpty;
  }
}

// "PurchaserInfo"{
//    "entitlements":"EntitlementInfos"{
//       "all":{
//          "Karaoke UNLIMITED":"EntitlementInfo"{
//             "identifier":"Karaoke UNLIMITED",
//             "isActive":false,
//             "willRenew":false,
//             "periodType":"PeriodType.normal",
//             "latestPurchaseDate":2020-12-13T06:55:52Z,
//             "originalPurchaseDate":2020-12-13T06:50:53Z,
//             "expirationDate":2020-12-13T07:00:52Z,
//             "store":"Store.appStore",
//             "productIdentifier":1m_399,
//             "isSandbox":true,
//             "unsubscribeDetectedAt":null,
//             "billingIssueDetectedAt":2020-12-13T07:02:33Z
//          }
//       },
//       "active":{

//       }
//    },
//    "latestExpirationDate":2020-12-13T07:00:52Z,
//    "allExpirationDates":{
//       1m_399:2020-12-13T07:00:52Z
//    },
//    "allPurchaseDates":{
//       1m_399:2020-12-13T06:55:52Z
//    },
//    "activeSubscriptions":[

//    ],
//    "allPurchasedProductIdentifiers":[
//       1m_399
//    ],
//    "firstSeen":2020-12-11T05:45:00Z,
//    "originalAppUserId":"deartovi@yahoo.com",
//    "requestDate":2020-12-13T07:02:33Z,
//    "originalApplicationVersion":1.0,
//    "originalPurchaseDate":2013-08-01T07:00:00Z,
//    "managementURL":null,
//    "nonSubscriptionTransactions":[

//    ]
// }

// "Purchaser info":"PurchaserInfo"{
//    "entitlements":"EntitlementInfos"{
//       "all":{
//          "Karaoke UNLIMITED":"EntitlementInfo"{
//             "identifier":"Karaoke UNLIMITED",
//             "isActive":true,
//             "willRenew":true,
//             "periodType":"PeriodType.normal",
//             "latestPurchaseDate":2020-12-13T06:50:52Z,
//             "originalPurchaseDate":2020-12-13T06:50:53Z,
//             "expirationDate":2020-12-13T06:55:52Z,
//             "store":"Store.appStore",
//             "productIdentifier":1m_399,
//             "isSandbox":true,
//             "unsubscribeDetectedAt":null,
//             "billingIssueDetectedAt":null
//          }
//       },
//       "active":{
//          "Karaoke UNLIMITED":"EntitlementInfo"{
//             "identifier":"Karaoke UNLIMITED",
//             "isActive":true,
//             "willRenew":true,
//             "periodType":"PeriodType.normal",
//             "latestPurchaseDate":2020-12-13T06:50:52Z,
//             "originalPurchaseDate":2020-12-13T06:50:53Z,
//             "expirationDate":2020-12-13T06:55:52Z,
//             "store":"Store.appStore",
//             "productIdentifier":1m_399,
//             "isSandbox":true,
//             "unsubscribeDetectedAt":null,
//             "billingIssueDetectedAt":null
//          }
//       }
//    },
//    "latestExpirationDate":2020-12-13T06:55:52Z,
//    "allExpirationDates":{
//       1m_399:2020-12-13T06:55:52Z
//    },
//    "allPurchaseDates":{
//       1m_399:2020-12-13T06:50:52Z
//    },
//    "activeSubscriptions":[
//       1m_399
//    ],
//    "allPurchasedProductIdentifiers":[
//       1m_399
//    ],
//    "firstSeen":2020-12-11T05:45:00Z,
//    "originalAppUserId":"deartovi@yahoo.com",
//    "requestDate":2020-12-13T06:53:18Z,
//    "originalApplicationVersion":1.0,
//    "originalPurchaseDate":2013-08-01T07:00:00Z,
//    "managementURL":"itms-apps":,
//    "nonSubscriptionTransactions":[

//    ]
// }

// "Offerings":"Offerings"{
//    "current":"Offering"{
//       "identifier":"Standard",
//       "serverDescription":"Grants access to Karaoke UNLIMITED.",
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
//             "offeringIdentifier":"Standard"
//          },
//          "Package"{
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
//             "offeringIdentifier":"Standard"
//          }
//       ],
//       "lifetime":null,
//       "annual":"Package"{
//          "identifier":"$rc_annual",
//          "packageType":"PackageType.annual",
//          "product":"Product"{
//             "identifier":1y_2499,
//             "description":"Save and send UNLIMITED Karaoke Cards.",
//             "title":"Karaoke UNLIMITED",
//             "price":24.489999771118164,
//             "priceString":$24.49,
//             "currencyCode":"USD",
//             "introductoryPrice":null
//          },
//          "offeringIdentifier":"Standard"
//       },
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
//          "offeringIdentifier":"Standard"
//       },
//       "weekly":null
//    },
//    "all":{
//       "Standard":"Offering"{
//          "identifier":"Standard",
//          "serverDescription":"Grants access to Karaoke UNLIMITED.",
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
//                "offeringIdentifier":"Standard"
//             },
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
//                "offeringIdentifier":"Standard"
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
//             "offeringIdentifier":"Standard"
//          },
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
//             "offeringIdentifier":"Standard"
//          },
//          "weekly":null
//       }
//    }
// }"flutter":"offerings available":[
//    "Package"{
//       "identifier":"$rc_monthly",
//       "packageType":"PackageType.monthly",
//       "product":"Product"{
//          "identifier":1m_399,
//          "description":"Save and send UNLIMITED Karaoke cards.",
//          "title":"Karaoke UNLIMITED",
//          "price":3.990000009536743,
//          "priceString":$3.99,
//          "currencyCode":"USD",
//          "introductoryPrice":null
//       },
//       "offeringIdentifier":"Standard"
//    },
//    "Package"{
//       "identifier":"$rc_annual",
//       "packageType":"PackageType.annual",
//       "product":"Product"{
//          "identifier":1y_2499,
//          "description":"Save and send UNLIMITED Karaoke Cards.",
//          "title":"Karaoke UNLIMITED",
//          "price":24.489999771118164,
//          "priceString":$24.49,
//          "currencyCode":"USD",
//          "introductoryPrice":null
//       },
//       "offeringIdentifier":"Standard"
//    }
// ]
