import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final String itemId = "68c73107cd4643458af014b47b8e3fa2";

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'subscription-screen';
  SubscriptionScreen();

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  TheUser user;

  makePurchase(package) {
    user.makePurchase(package);
  }

  Column purchaseButtons() {
    return Column(
      children: user.packages
          .map(
            (Package package) => RawMaterialButton(
              onPressed: () => makePurchase(package),
              child: Text(
                package.product.priceString,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 2.0,
              fillColor: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 75)),
            Center(
              child: Text(
                "YOUR SUBSCRIPTION IS",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
            ),
            Center(
              child: Text(
                user.hasActiveSubscription ? "ACTIVE" : "INACTIVE",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
            ),
            Center(
              child: Text(
                "WOULD YOU LIKE TO SUBSCRIBE TO A PLAN?",
                style: TextStyle(fontSize: 20),
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
        ),
      ),
    );
  }
}
