import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/terms_of_use.dart';
import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  static const routeName = 'terms-of-use-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(isMenu: true, pageTitle: "Terms of Use"),
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
            TermsOfUse(),
          ],
        ),
      ),
    );
  }
}
