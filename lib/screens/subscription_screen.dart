import 'package:K9_Karaoke/providers/the_user.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final String itemId = "68c73107cd4643458af014b47b8e3fa2";

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'subscription-screen';
  SubscriptionScreen();

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  TheUser user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<TheUser>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context, isMenu: true, pageTitle: "Subscription"),
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
          children: [
            Padding(padding: EdgeInsets.only(top: 75)),
            Center(
                child: Text(user.hasActiveSubscription
                    ? "Subscribed"
                    : "Not Subscribed")),
            Center(
              child: RawMaterialButton(
                child: Text("Buy Subscription"),
                onPressed: null,
              ),
            ),
            FutureBuilder(
              future: user.getOfferings(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return Text("Packages: ${user.packages}");
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
