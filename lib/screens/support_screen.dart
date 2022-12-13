import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = 'support-screen';

  final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@turboblasterunlimited.com',
      queryParameters: {'subject': 'Help'});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

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
              padding: EdgeInsets.only(top: 70, bottom: 10),
              child: InterfaceTitleNav(
                title: "SUPPORT",
                titleSize: 22,
                backCallback: () => Navigator.of(context)
                    .popAndPushNamed(AboutScreen.routeName),
              ),
            ),
            // Center(
            //   child: Text("Email Us!",
            //       style: TextStyle(
            //           color: Theme.of(context).primaryColor, fontSize: 20)),
            // ),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: style,
                  onPressed: () => {launch(emailUri.toString())},
                  child: const Text('Email Us!'),
                ),
                // child: GestureDetector(
                //   onTap: () => {launch(emailUri.toString())},
                //   child: Text(
                //     "Email us!\n\nsupport@turboblasterunlimited.com",
                //     style: TextStyle(
                //         fontSize: 20, color: Theme.of(context).primaryColor),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
