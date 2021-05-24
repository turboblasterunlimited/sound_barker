import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:K9_Karaoke/widgets/interface_title_nav.dart';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/widgets/info.dart';

import 'menu_screen.dart';

class InfoScreen extends StatelessWidget {
  static const routeName = 'info-screen';
  static const infoText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isMenu: false, noName: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backgrounds/menu_background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    // Padding(padding: EdgeInsets.only(top: 75)),
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 10),
                      child: InterfaceTitleNav(
                        title: "HOW TO USE",
                        titleSize: 22,
                        backCallback: () => Navigator.of(context)
                            .popAndPushNamed(MenuScreen.routeName),
                      ),
                    ),
                    Info(),
                    Padding(padding: EdgeInsets.only(top: 75)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
