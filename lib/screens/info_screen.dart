import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:K9_Karaoke/widgets/info.dart';

class InfoScreen extends StatelessWidget {
  static const routeName = 'info-screen';
  static const infoText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isMenu: true, pageTitle: "How To Use"),
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
                    Padding(padding: EdgeInsets.only(top: 75)),
                    Info(),
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
