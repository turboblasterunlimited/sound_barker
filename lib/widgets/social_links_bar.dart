import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

const faceBookURL = "https://www.facebook.com/K9Karaoke1/";
const instagramURL = "https://www.instagram.com/ribbond_dental/";

void _launchFacebook() async => await canLaunch(faceBookURL)
    ? await launch(faceBookURL)
    : throw 'Could not launch $faceBookURL';

void _launchInstagram() async => await canLaunch(instagramURL)
    ? await launch(instagramURL)
    : throw 'Could not launch $instagramURL';

Widget socialLinksBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      RawMaterialButton(
        onPressed: _launchFacebook,
        child: Image.asset(
          "assets/logos/facebook256.png",
          height: 40,
          width: 40,
          fit: BoxFit.fitWidth,
        ),
        padding: const EdgeInsets.all(10.0),
      ),
      RawMaterialButton(
        onPressed: _launchInstagram,
        child: Image.asset(
          "assets/logos/Instagram_AppIcon_Aug2017.png",
          height: 40,
          width: 40,
          fit: BoxFit.fitWidth,
        ),
        padding: const EdgeInsets.all(10.0),
      ),
      // RawMaterialButton(
      //   onPressed: null,
      //   child: Image.asset(
      //     "assets/logos/Twitter social icons - rounded square - blue.png",
      //     height: 40,
      //     width: 40,
      //     fit: BoxFit.fitWidth,
      //   ),
      //   padding: const EdgeInsets.all(10.0),
      // ),
    ],
  );
}
