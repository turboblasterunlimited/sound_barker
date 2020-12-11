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

  ButtonBar purchaseButtons() {
    return ButtonBar(
      children: user.packages.map(
        (Package e) => MaterialButton(
          height: 20,
          minWidth: 50,
          onPressed: null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: FittedBox(
              child: Text(
                e.product.identifier,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 2.0,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 2),
        ),
      ).toList(),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 75)),
            Center(
                child: Text(user.hasActiveSubscription
                    ? "Subscribed"
                    : "Not Subscribed")),
            Center(
              child: Text(
                "Buy Subscription",
                style: TextStyle(fontSize: 20),
              ),
            ),
            FutureBuilder(
              future: user.getOfferings(),
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
