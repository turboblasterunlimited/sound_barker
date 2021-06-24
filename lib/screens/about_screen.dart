import 'package:K9_Karaoke/screens/privacy_policy_screen.dart';
import 'package:K9_Karaoke/screens/support_screen.dart';
import 'package:K9_Karaoke/screens/terms_of_use_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/about.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';

import 'menu_screen.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(isMenu: false, noName: true),
      body: SingleChildScrollView(
        child: Container(
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
                Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 10),
                  child: InterfaceTitleNav(
                    title: "ABOUT",
                    titleSize: 22,
                    backCallback: () => Navigator.of(context)
                        .popAndPushNamed(MenuScreen.routeName),
                  ),
                ),
                About(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(TermsOfUseScreen.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Terms Of Use",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(PrivacyPolicyScreen.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Privacy Policy",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(SupportScreen.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Support",
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
