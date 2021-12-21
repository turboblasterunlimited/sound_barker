import 'package:K9_Karaoke/screens/about_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:K9_Karaoke/widgets/terms_of_use.dart';
import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  static const routeName = 'terms-of-use-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
          isMenu: false, /*pageTitle: "Terms of Use"*/ noName: true),
      // Background image
      body: Container(
        padding: EdgeInsets.only(top: 60),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 70, bottom: 10),
              child: InterfaceTitleNav(
                title: "TERMS OF USE",
                titleSize: 22,
                backCallback: () => Navigator.of(context)
                    .popAndPushNamed(AboutScreen.routeName),
              ),
            ),
            TermsOfUse(),
          ],
        ),
      ),
    );
  }
}
