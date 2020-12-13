import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'subscription-screen';
  SubscriptionScreen();

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  TheUser user;

  makePurchase(Package package) {
    user.makePurchase(package);
  }

  String getSubscriptionType(Package package) {
    return capitalize(getSubscriptionName(package)) + " Subscription";
  }

  String getSubscriptionName(package) {
    return package.packageType.toString().split('.').last;
  }

  String capitalize(String string) {
    return "${string[0].toUpperCase()}${string.substring(1)}";
  }

  Column purchaseButtons() {
    return Column(
      children: user.packages
          .map(
            (Package package) => Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  RawMaterialButton(
                    onPressed: () => makePurchase(package),
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

  @override
  Widget build(BuildContext context) {
    user = Provider.of<TheUser>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(isMenu: true, pageTitle: "Subscription"),
      // Background image
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backgrounds/menu_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: user.hasActiveSubscription
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 75)),
                    Center(
                      child: Text(
                        "YOUR SUBSCRIPTION IS",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        "INACTIVE",
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).errorColor),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "WOULD YOU LIKE TO SUBSCRIBE TO A PLAN?",
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: user.getPackages(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done)
                          return purchaseButtons();
                        else
                          return Text("LOADING LOADING");
                      },
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 75)),
                    Center(
                      child: Text(
                        "YOUR ${getSubscriptionName(user.getCurrentPackage())} SUBSCRIPTION IS",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        "ACTIVE",
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).errorColor),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "WOULD YOU LIKE TO SUBSCRIBE TO A PLAN?",
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: user.getPackages(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done)
                          return purchaseButtons();
                        else
                          return Text("LOADING LOADING");
                      },
                    ),
                  ],
                ),),
    );
  }
}
