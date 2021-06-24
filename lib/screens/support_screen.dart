import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = 'support-screen';

  final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'Support@TurboBlasterUnlimited.com',
      queryParameters: {'subject': 'Help'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(isMenu: false, noName: true),
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
              padding: EdgeInsets.only(top: 0, bottom: 10),
              child: InterfaceTitleNav(
                title: "SUPPORT",
                titleSize: 22,
                backCallback: () => Navigator.of(context)
                    .popAndPushNamed(AboutScreen.routeName),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => {launch(emailUri.toString())},
                  child: Text(
                    "Email us!\n\nSupport@TurboBlasterUnlimited.com",
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
