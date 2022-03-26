import 'package:K9_Karaoke/providers/current_activity.dart';
import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/screens/main_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/error_dialog.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/loading_half_screen_widget.dart';
import 'package:K9_Karaoke/widgets/manage_subscriptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:purchases_flutter/purchases_flutter.dart';

import 'account_screen.dart';
import 'menu_screen.dart';

const String apple_subscription = "Subscription Provider: Apple\n\n";
const String apple_management_info1 = "Go to Settings on your iOS device.\n";
const String apple_management_info2 =
    "Tap to Settings/AppleID/Subscriptions.\n";

const String google_subscription = "Subscription Provider: Google Play.\n\n";
const String google_management_info1 =
    "Open the Google Play app on your Android device.\n";
const String google_management_info2 = "Tap profile icon (top right).\n";
const String google_management_info3 =
    "Tap Payments & subscriptions then tap Subscriptions\n";

const String common_management_info1 = "To manage your subscription:\n";
const String common_management_info2 = "Tap K-9 Karaoke.\n";
const String common_management_info3 =
    "Tap desired option to change or cancel the subscription";

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'subscription-screen';
  SubscriptionScreen();

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late TheUser user;
  late CurrentActivity currentActivity;

  makePurchase(BuildContext ctx, Package package) {
    Function errorCallback = (errorMessage) => showError(ctx, errorMessage);
    user.makePurchase(package, errorCallback);
  }

  String getSubscriptionType(Package package) {
    return capitalize(getSubscriptionName(package)) + " Subscription";
  }

  // monthly OR yearly
  String getSubscriptionName(package) {
    return package.packageType.toString().split('.').last;
  }

  String capitalize(String string) {
    return "${string[0].toUpperCase()}${string.substring(1)}";
  }

  Column purchaseButtons(ctx) {
    print("purchase buttons init");
    List<Package> inactivePackages = user.getInactivePackages()!;
    print("inactive packages: $inactivePackages");
    return Column(
      children: inactivePackages
          .map(
            (Package package) => Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  RawMaterialButton(
                    onPressed: () => makePurchase(ctx, package),
                    child: Text(
                      getSubscriptionType(package),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 2.0,
                    fillColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15),
                  ),
                  Center(
                    child: Text(
                      package.product.priceString,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // void goToMainMenu(context) {
  //   if (currentActivity.isCreateCard) {
  //     Navigator.of(context).popUntil(ModalRoute.withName(MainScreen.routeName));
  //   } else {
  //     SystemChrome.setEnabledSystemUIOverlays([]);
  //     Navigator.of(context).pushNamed(MenuScreen.routeName);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print("building subscription screen");
    user = Provider.of<TheUser>(context);
    currentActivity = Provider.of<CurrentActivity>(context, listen: false);

    var subscription = user.getSubscriptionProvider();
    var subName = user.getSubscriptionName();

    var reg = TextStyle(
        fontFamily: "Museo",
        fontSize: 15,
        color: Theme.of(context).primaryColor);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(noName: true),
      // Background image
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Builder(
          builder: (BuildContext ctx) {
            return user.isLoading
                ? Column(
                    children: [LoadingHalfScreenWidget("Processing Payment")],
                  )
                : !user.subscribed
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 125)),
                          Padding(
                            padding: EdgeInsets.only(top: 0, bottom: 10),
                            child: InterfaceTitleNav(
                              title: "SUBSCRIPTION ",
                              titleSize: 20,
                              backCallback: () => Navigator.of(context)
                                  .popAndPushNamed(AccountScreen.routeName),
                            ),
                          ),
                          Center(
                            child: Text(
                              "YOUR SUBSCRIPTION IS",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Text(
                              "INACTIVE",
                              style: TextStyle(
                                  fontFamily: "Museo",
                                  fontSize: 20,
                                  color: Theme.of(context).errorColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "WOULD YOU LIKE TO SUBSCRIBE TO A PLAN?",
                                style: TextStyle(
                                    fontFamily: "Museo",
                                    fontSize: 20,
                                    color: Theme.of(context).primaryColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          purchaseButtons(ctx),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(top: 75)),
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        "YOUR ${(user.getSubscriptionName().toUpperCase())} SUBSCRIPTION\nIS",
                                    style: TextStyle(
                                        fontFamily: "Museo",
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  TextSpan(
                                    text: ' ACTIVE',
                                    style: TextStyle(
                                        fontFamily: "Museo",
                                        fontSize: 20,
                                        color:
                                            Theme.of(context).highlightColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // if (subName == "monthly")
                          //   Center(
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(20.0),
                          //       child: Text(
                          //         "WOULD YOU LIKE TO CHANGE YOUR PLAN?",
                          //         style: TextStyle(
                          //             fontSize: 20,
                          //             color: Theme.of(context).primaryColor),
                          //         textAlign: TextAlign.center,
                          //       ),
                          //     ),
                          //   ),
                          // purchaseButtons(ctx),
                          if (currentActivity.isCreateCard)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: RawMaterialButton(
                                  onPressed: () => Navigator.of(context)
                                      .popUntil(ModalRoute.withName(
                                          MainScreen.routeName)),
                                  child: Text(
                                    "Get back to barking!",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 2.0,
                                  fillColor: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0, vertical: 2),
                                ),
                              ),
                            ),

                          // if (user.subscribed)
                          //   Center(
                          //     child: Padding(
                          //       padding: const EdgeInsets.only(
                          //           left: 8.0, right: 8.0, top: 20),
                          //       child: RawMaterialButton(
                          //         onPressed: () => Navigator.of(context)
                          //             .pushNamed(ManageSubscriptions.routeName),
                          //         child: Text(
                          //           "Manage Subscriptions",
                          //           style: TextStyle(color: Colors.white),
                          //         ),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(30.0),
                          //         ),
                          //         elevation: 2.0,
                          //         fillColor: Theme.of(context).primaryColor,
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 40.0, vertical: 2),
                          //       ),
                          //     ),
                          //   ),

                          Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: RichText(
                                    text: subscription == 'apple'
                                        ? TextSpan(
                                            style: reg,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: apple_subscription,
                                                  style: reg),
                                              TextSpan(
                                                  text: common_management_info1,
                                                  style: reg),
                                              TextSpan(
                                                  text: apple_management_info1,
                                                  style: reg),
                                              TextSpan(
                                                  text: apple_management_info2,
                                                  style: reg),
                                              TextSpan(
                                                  text: common_management_info2,
                                                  style: reg),
                                            ],
                                          )
                                        : TextSpan(
                                            style: reg,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: google_subscription,
                                                  style: reg),
                                              TextSpan(
                                                  text: common_management_info1,
                                                  style: reg),
                                              TextSpan(
                                                  text: google_management_info1,
                                                  style: reg),
                                              TextSpan(
                                                  text: google_management_info2,
                                                  style: reg),
                                              TextSpan(
                                                  text: google_management_info3,
                                                  style: reg),
                                              TextSpan(
                                                  text: common_management_info2,
                                                  style: reg),
                                              TextSpan(
                                                  text: common_management_info3,
                                                  style: reg),
                                            ],
                                          ),
                                  ))),
                          // RichText(
                          //   text: subscription == 'apple'
                          //       ? TextSpan(
                          //           style: reg,
                          //           children: <TextSpan>[
                          //             TextSpan(
                          //                 text: apple_subscription, style: reg),
                          //             TextSpan(
                          //                 text: common_management_info1,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: apple_management_info1,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: apple_management_info2,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: common_management_info2,
                          //                 style: reg),
                          //           ],
                          //         )
                          //       : TextSpan(
                          //           style: reg,
                          //           children: <TextSpan>[
                          //             TextSpan(
                          //                 text: google_subscription,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: common_management_info1,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: google_management_info1,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: google_management_info2,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: google_management_info3,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: common_management_info2,
                          //                 style: reg),
                          //             TextSpan(
                          //                 text: common_management_info3,
                          //                 style: reg),
                          //           ],
                          //         ),
                          // ),
                          // Flexible(
                          //   fit: FlexFit.loose,
                          //   child: Align(
                          //     alignment: Alignment.topCenter,
                          //     child: RichText(
                          //       text: subscription == 'apple'
                          //           ? TextSpan(
                          //               style: reg,
                          //               children: <TextSpan>[
                          //                 TextSpan(
                          //                     text: apple_subscription,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: common_management_info1,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: apple_management_info1,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: apple_management_info2,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: common_management_info2,
                          //                     style: reg),
                          //               ],
                          //             )
                          //           : TextSpan(
                          //               style: reg,
                          //               children: <TextSpan>[
                          //                 TextSpan(
                          //                     text: google_subscription,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: common_management_info1,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: google_management_info1,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: google_management_info2,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: google_management_info3,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: common_management_info2,
                          //                     style: reg),
                          //                 TextSpan(
                          //                     text: common_management_info3,
                          //                     style: reg),
                          //               ],
                          //             ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
          },
        ),
      ),
    );
  }
}
