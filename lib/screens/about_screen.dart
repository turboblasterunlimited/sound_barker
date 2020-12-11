import 'package:K9_Karaoke/screens/privacy_policy_screen.dart';
import 'package:K9_Karaoke/screens/terms_of_use_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(isMenu: true, pageTitle: "About"),
      body: Container(
        padding: EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print("terms of use tapped");
                  Navigator.of(context).pushNamed(TermsOfUseScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Terms Of Use",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("terms of use tapped");
                  Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Privacy Policy",
                      style: TextStyle(
                          fontSize: 40, color: Theme.of(context).primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
